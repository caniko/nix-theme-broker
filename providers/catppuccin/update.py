#!/usr/bin/env python3
"""Validate a pinned Catppuccin palette checkout outside Nix evaluation."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


VARIANTS = ("latte", "frappe", "macchiato", "mocha")
ACCENTS = (
    "rosewater", "flamingo", "pink", "mauve", "red", "maroon", "peach",
    "yellow", "green", "teal", "sky", "sapphire", "blue", "lavender",
)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("palette", type=Path, help="catppuccin/palette checkout")
    args = parser.parse_args()
    path = args.palette / "palette.json"
    if not path.is_file():
        parser.error(f"missing palette.json: {path}")
    data = json.loads(path.read_text(encoding="utf-8"))
    missing_variants = sorted(set(VARIANTS) - set(data))
    missing_accents = {
        variant: sorted(set(ACCENTS) - set(data[variant].get("colors", {})))
        for variant in VARIANTS
        if variant in data
    }
    missing = {variant: names for variant, names in missing_accents.items() if names}
    if missing_variants or missing:
        if missing_variants:
            print("error: missing variants: " + ", ".join(missing_variants))
        for variant, names in missing.items():
            print(f"error: {variant}: missing accents: {', '.join(names)}")
        return 1
    print(f"{path}: {len(VARIANTS)} variants, {len(ACCENTS)} accents, revision review required")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
