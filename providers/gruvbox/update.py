#!/usr/bin/env python3
"""Validate the reviewed Gruvbox palette snapshot.

The updater is intentionally outside Nix evaluation.  A maintainer runs it
from a checked-out upstream morhetz/gruvbox tree, reviews the resulting JSON
diff, and then commits the snapshot used by the provider.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


VARIANTS = (
    "dark-hard",
    "dark-medium",
    "dark-soft",
    "light-hard",
    "light-medium",
    "light-soft",
)
BASE16 = tuple(
    [f"base{i:02X}" for i in range(16)]
)


def load(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def validate(data: dict) -> list[str]:
    errors: list[str] = []
    if data.get("schema") != "theme-broker.gruvbox-palette/v1":
        errors.append("schema must be theme-broker.gruvbox-palette/v1")
    for field in ("source", "generated", "named", "variants"):
        if not isinstance(data.get(field), dict):
            errors.append(f"{field} must be an object")
    for variant in VARIANTS:
        entry = data.get("variants", {}).get(variant)
        if not isinstance(entry, dict):
            errors.append(f"missing variant {variant}")
            continue
        missing = sorted(set(BASE16) - set(entry.get("base16", {})))
        if missing:
            errors.append(f"{variant}: missing Base16 keys: {', '.join(missing)}")
    return errors


def parse_vim(source: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    pattern = re.compile(r"^let s:gb\.([a-z0-9_]+)\s*=\s*\['(#[0-9A-Fa-f]{6})'")
    for line in source.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line.strip())
        if match:
            values[match.group(1)] = match.group(2).lower()
    return values


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--palette",
        type=Path,
        default=Path(__file__).with_name("palette.json"),
        help="reviewed palette snapshot to validate",
    )
    parser.add_argument(
        "--source",
        type=Path,
        help="optional upstream checkout; only its existence is checked",
    )
    args = parser.parse_args()
    if args.source is not None and not args.source.is_dir():
        parser.error(f"upstream checkout does not exist: {args.source}")
    data = load(args.palette)
    errors = validate(data)
    if args.source is not None:
        vim = args.source / "colors/gruvbox.vim"
        if not vim.is_file():
            errors.append(f"missing canonical source file: {vim}")
        else:
            source_values = parse_vim(vim)
            for name, value in data.get("named", {}).items():
                source_name = "gray_245" if name == "gray" else name
                if source_name not in source_values:
                    errors.append(f"canonical source has no named color {name}")
                elif source_values[source_name] != value:
                    errors.append(f"{name}: snapshot {value} != source {source_values[source_name]}")
    if errors:
        for error in errors:
            print(f"error: {error}")
        return 1
    print(
        f"{args.palette}: {len(data['variants'])} variants, "
        f"{len(data['named'])} named colors, source revision "
        f"{data['source']['revision']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
