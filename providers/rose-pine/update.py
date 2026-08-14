#!/usr/bin/env python3
"""Validate the reviewed Rosé Pine snapshot against an explicit checkout."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


VARIANTS = ("main", "moon", "dawn")
ACCENTS = ("love", "gold", "rose", "pine", "foam", "iris")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path, help="rose-pine/rose-pine-palette checkout")
    parser.add_argument(
        "--snapshot",
        type=Path,
        default=Path(__file__).with_name("palette.json"),
        help="reviewed snapshot to compare",
    )
    args = parser.parse_args()
    source_path = args.source / "palette.json"
    snapshot_path = args.snapshot
    if not source_path.is_file():
        parser.error(f"missing palette.json: {source_path}")
    source = json.loads(source_path.read_text(encoding="utf-8"))
    snapshot = json.loads(snapshot_path.read_text(encoding="utf-8"))
    failures: list[str] = []
    for variant in VARIANTS:
        observed = {entry["role"]: f'#{entry["hex"].lower()}' for entry in source.get(variant, [])}
        expected = snapshot.get("variants", {}).get(variant, {}).get("colors", {})
        for role in ("base", "surface", "overlay", "muted", "subtle", "text", *ACCENTS):
            if observed.get(role) != expected.get(role):
                failures.append(f"{variant}/{role}: source={observed.get(role)} snapshot={expected.get(role)}")
    if failures:
        print("\n".join(f"error: {failure}" for failure in failures))
        return 1
    print(f"{snapshot_path}: {len(VARIANTS)} variants and {len(ACCENTS)} accents match {source_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
