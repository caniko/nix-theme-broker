#!/usr/bin/env python3
"""Validate the reviewed Rosé Pine snapshot against an explicit checkout."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


VARIANTS = ("main", "moon", "dawn")
ROLES = (
    "base",
    "surface",
    "overlay",
    "muted",
    "subtle",
    "text",
    "love",
    "gold",
    "rose",
    "pine",
    "foam",
    "iris",
    "highlightLow",
    "highlightMed",
    "highlightHigh",
)


def read_source(path: Path) -> dict[str, dict[str, str]]:
    text = path.read_text(encoding="utf-8")
    colors: dict[str, dict[str, str]] = {}
    for variant in VARIANTS:
        marker = f"const {variant} = {{"
        start = text.find(marker)
        if start < 0:
            raise ValueError(f"missing {marker}")
        end = text.find("\n};", start)
        if end < 0:
            raise ValueError(f"unterminated {variant} palette")
        block = text[start:end]
        colors[variant] = {
            role: f"#{value.lower()}"
            for role, value in re.findall(
                r"^\s*([A-Za-z][A-Za-z0-9]*):\s*\{\s*hex:\s*\"([0-9A-Fa-f]{6})\"",
                block,
                re.MULTILINE,
            )
        }
    return colors


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
    source_path = args.source / "source" / "index.ts"
    snapshot_path = args.snapshot
    if not source_path.is_file():
        parser.error(f"missing source/index.ts: {source_path}")
    source = read_source(source_path)
    snapshot = json.loads(snapshot_path.read_text(encoding="utf-8"))
    failures: list[str] = []
    if snapshot.get("source", {}).get("path") != "source/index.ts":
        failures.append("snapshot source path is not source/index.ts")
    for variant in VARIANTS:
        observed = source.get(variant, {})
        expected = snapshot.get("variants", {}).get(variant, {}).get("colors", {})
        for role in ROLES:
            if observed.get(role) != expected.get(role):
                failures.append(f"{variant}/{role}: source={observed.get(role)} snapshot={expected.get(role)}")
    if failures:
        print("\n".join(f"error: {failure}" for failure in failures))
        return 1
    print(f"{snapshot_path}: {len(VARIANTS)} variants and {len(ROLES)} roles match {source_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
