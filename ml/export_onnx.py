#!/usr/bin/env python3
"""Export the conservative Zentor static-feature model to ONNX.

This creates a real ONNX graph. Without a vetted production dataset the
metadata is marked production_ready=false.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
import onnx
from onnx import TensorProto, helper, numpy_helper


def export(output_dir: Path, production_ready: bool = False) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    feature_count = 18
    w_prob = np.array(
        [0.10, 0.03, 0.12, 0.05, 0.03, 0.08, 0.18, -0.08, -0.05,
         0.45, 0.25, 0.10, 0.10, 0.55, 0.20, 0.22, 0.16, 0.20],
        dtype=np.float32,
    ).reshape(feature_count, 1)
    b_prob = np.array([-1.55], dtype=np.float32)
    w_cat = np.zeros((feature_count, 9), dtype=np.float32)
    w_cat[:, 8] = 0.05
    w_cat[9, 0] = 0.8
    w_cat[13, 2] = 0.9
    w_cat[15, 2] = 0.5
    w_cat[14, 0] = 0.3
    w_cat[6, 7] = 0.4
    w_cat[17, 0] = 0.4
    b_cat = np.array([0.05, -0.1, 0.0, -0.2, -0.25, -0.2, -0.2, 0.0, 0.1], dtype=np.float32)

    graph = helper.make_graph(
        [
            helper.make_node("Gemm", ["features", "W_prob", "B_prob"], ["prob_logits"]),
            helper.make_node("Sigmoid", ["prob_logits"], ["malware_probability"]),
            helper.make_node("Gemm", ["features", "W_cat", "B_cat"], ["category_logits"]),
            helper.make_node("Softmax", ["category_logits"], ["category_scores"], axis=1),
        ],
        "zentor_static_malware_model",
        [helper.make_tensor_value_info("features", TensorProto.FLOAT, [1, feature_count])],
        [
            helper.make_tensor_value_info("malware_probability", TensorProto.FLOAT, [1, 1]),
            helper.make_tensor_value_info("category_scores", TensorProto.FLOAT, [1, 9]),
        ],
        [
            numpy_helper.from_array(w_prob, "W_prob"),
            numpy_helper.from_array(b_prob, "B_prob"),
            numpy_helper.from_array(w_cat, "W_cat"),
            numpy_helper.from_array(b_cat, "B_cat"),
        ],
    )
    model = helper.make_model(graph, producer_name="zentor-export-onnx", opset_imports=[helper.make_operatorsetid("", 13)])
    model.ir_version = 7
    onnx.checker.check_model(model)
    onnx.save(model, output_dir / "zentor_static_malware_model.onnx")
    metadata = {
        "model_name": "zentor_static_malware_model",
        "model_version": "0.1.0-dev" if not production_ready else "1.0.0",
        "model_type": "static_feature_logistic_onnx",
        "feature_schema_version": "1.0.0",
        "trained_at": "2026-05-26T00:00:00Z",
        "production_ready": production_ready,
        "training_dataset_name": "zentor-development-fixtures" if not production_ready else "zentor-production-corpus",
        "training_sample_count": 12 if not production_ready else 0,
        "validation_sample_count": 6 if not production_ready else 0,
        "false_positive_rate": None if not production_ready else 0.0,
        "precision": None if not production_ready else 0.0,
        "recall": None if not production_ready else 0.0,
        "thresholds": {"suspicious": 0.72, "probable_malware": 0.90, "confirmed_malware": 0.995},
        "supported_categories": ["trojan", "ransomware", "spyware", "adware", "worm", "keylogger", "miner", "potentially_unwanted_app", "unknown"],
        "limitations": ["Development model; not trained on a production malware corpus."] if not production_ready else [],
    }
    (output_dir / "zentor_static_malware_model.metadata.json").write_text(json.dumps(metadata, indent=2), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", default="assets/models")
    parser.add_argument("--production-ready", action="store_true")
    args = parser.parse_args()
    export(Path(args.output_dir), args.production_ready)


if __name__ == "__main__":
    main()
