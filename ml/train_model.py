#!/usr/bin/env python3
"""Train a conservative offline Pasus static malware classifier.

This script is a developer pipeline. The production Pasus app never retrains
itself silently from one user's labels.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def load_jsonl(path: Path) -> list[dict]:
    rows: list[dict] = []
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, help="Training labels JSONL")
    parser.add_argument("--output", required=True, help="Output directory")
    args = parser.parse_args()

    rows = load_jsonl(Path(args.input))
    if len(rows) < 50:
        raise SystemExit("Need at least 50 labeled records before training.")

    malicious = sum(1 for row in rows if row.get("user_label") == "confirmedMalicious")
    false_positive = sum(
        1
        for row in rows
        if row.get("user_label") in {"falsePositive", "trustedApp"}
    )

    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    metadata = {
        "model_version": "dev-untrained",
        "feature_schema_version": "1.0.0",
        "records": len(rows),
        "confirmed_malicious_labels": malicious,
        "false_positive_or_trusted_labels": false_positive,
        "threshold_policy": {
            "suspicious": 0.75,
            "probable_malware": 0.92,
            "auto_quarantine_requires_behavior_or_signature": True,
        },
        "note": "Install scikit-learn/skl2onnx in the training environment to fit and export the classifier.",
    }
    (output / "model_metadata.json").write_text(
        json.dumps(metadata, indent=2), encoding="utf-8"
    )
    print(json.dumps(metadata, indent=2))


if __name__ == "__main__":
    main()
