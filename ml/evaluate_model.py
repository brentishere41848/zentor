#!/usr/bin/env python3
"""Evaluate a Zentor offline model export.

This placeholder enforces that model releases include measured false-positive
rates before deployment.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--metadata", required=True)
    args = parser.parse_args()
    metadata = json.loads(Path(args.metadata).read_text(encoding="utf-8"))
    metrics = metadata.get("metrics", {})
    if "false_positive_rate" not in metrics:
        raise SystemExit("Model metadata is missing false_positive_rate.")
    print(json.dumps(metrics, indent=2))


if __name__ == "__main__":
    main()
