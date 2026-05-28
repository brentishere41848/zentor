#!/usr/bin/env python3
"""Build Zentor feature JSONL rows from already-extracted metadata.

This script does not execute files, detonate samples, download malware, or
upload user data. It validates feature rows for the offline training pipeline.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    rows = []
    with Path(args.input).open("r", encoding="utf-8") as handle:
        for line in handle:
            if line.strip():
                rows.append(json.loads(line))

    with Path(args.output).open("w", encoding="utf-8") as handle:
        for row in rows:
            if "extracted_features" not in row:
                raise SystemExit("row missing extracted_features")
            handle.write(json.dumps(row) + "\n")

    print(f"wrote {len(rows)} feature rows")


if __name__ == "__main__":
    main()
