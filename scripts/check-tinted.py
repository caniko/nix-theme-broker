#!/usr/bin/env python3
"""Compare every built-in Base16 projection with the pinned Tinted source."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


SCHEMES = {
    "catppuccin": {
        "latte": "catppuccin-latte",
        "frappe": "catppuccin-frappe",
        "macchiato": "catppuccin-macchiato",
        "mocha": "catppuccin-mocha",
    },
    "gruvbox": {
        "dark-hard": "gruvbox-dark-hard",
        "dark-medium": "gruvbox-dark-medium",
        "dark-soft": "gruvbox-dark-soft",
        "light-hard": "gruvbox-light-hard",
        "light-medium": "gruvbox-light-medium",
        "light-soft": "gruvbox-light-soft",
    },
    "rose-pine": {
        "main": "rose-pine",
        "moon": "rose-pine-moon",
        "dawn": "rose-pine-dawn",
    },
}
BASE16_LINE = re.compile(r'^\s+(base(?:0[0-9A-Fa-f])):\s*["\']?(#[0-9A-Fa-f]{6})')


def read_scheme(path: Path) -> dict[str, str]:
    palette: dict[str, str] = {}
    in_palette = False
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.strip() == "palette:":
            in_palette = True
            continue
        if in_palette:
            match = BASE16_LINE.match(line)
            if match:
                palette[match.group(1)] = match.group(2).lower()
    return palette


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, type=Path, help="realized tinted-theming/schemes checkout")
    parser.add_argument("--actual", required=True, type=Path, help="JSON generated from the normalized providers")
    args = parser.parse_args()

    actual = json.loads(args.actual.read_text(encoding="utf-8"))
    failures: list[str] = []
    checked = 0
    for provider, variants in SCHEMES.items():
        for variant, scheme in variants.items():
            path = args.source / "base16" / f"{scheme}.yaml"
            if not path.is_file():
                failures.append(f"{provider}/{variant}: missing {path}")
                continue
            expected = read_scheme(path)
            observed = actual[provider][variant]
            checked += 1
            if set(expected) != set(observed):
                failures.append(
                    f"{provider}/{variant}: Base16 keys differ: "
                    f"source={sorted(expected)} actual={sorted(observed)}"
                )
                continue
            for key, value in expected.items():
                if observed[key].lower() != value:
                    failures.append(
                        f"{provider}/{variant}/{key}: source={value} actual={observed[key]}"
                    )

    if failures:
        print("\n".join(failures))
        return 1
    print(f"checked {checked} Tinted Base16 schemes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
