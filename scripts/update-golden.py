#!/usr/bin/env python3
"""Regenerate or verify the reviewed normalized-theme golden fixtures."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path


FIXTURES = {
    "catppuccin-latte-blue": ("catppuccin", "latte", "blue"),
    "catppuccin-mocha-mauve": ("catppuccin", "mocha", "mauve"),
    "gruvbox-dark-medium": ("gruvbox", "dark-medium", None),
    "gruvbox-light-hard": ("gruvbox", "light-hard", None),
    "rose-pine-main-rose": ("rose-pine", "main", "rose"),
    "rose-pine-moon-iris": ("rose-pine", "moon", "iris"),
    "rose-pine-dawn-pine": ("rose-pine", "dawn", "pine"),
}
TINTED_SOURCE = {
    "repository": "https://github.com/tinted-theming/schemes",
    "revision": "9bd28ed313560db3c5b605c63bc4e309e78e3fc8",
}


def nix_string(value: str) -> str:
    return json.dumps(value)


def evaluate(repo: Path, provider: str, variant: str, accent: str | None) -> dict:
    accent_expr = "null" if accent is None else nix_string(accent)
    expression = f"""
let
  flake = builtins.getFlake (toString {nix_string(str(repo))});
  lib = flake.outputs.lib;
  selected = lib.resolveSelection {{
    providers = lib.providers;
    selection = {{
      provider = {nix_string(provider)};
      variant = {nix_string(variant)};
      accent = {accent_expr};
    }};
  }};
in {{
  provider = selected.provider;
  variant = selected.variant;
  accent = selected.accent;
  background = selected.roles.ui.background.withHashtag;
  accentColor = if selected.accent == null then null else selected.roles.ui.accent.withHashtag;
  base16 = builtins.mapAttrs (_: color: color.withHashtag) selected.base16;
}}
"""
    result = subprocess.run(
        ["nix", "eval", "--impure", "--no-update-lock-file", "--json", "--expr", expression],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def expected(actual: dict, current: dict | None) -> dict:
    output = {
        "source": current.get("source", TINTED_SOURCE) if current else TINTED_SOURCE,
        "provider": actual["provider"],
        "variant": actual["variant"],
        "accent": actual["accent"],
    }
    if current and "base00" in current:
        output["base00"] = actual["base16"]["base00"]
    output["background"] = actual["background"]
    if actual["accentColor"] is not None:
        output["accentColor"] = actual["accentColor"]
    output["base16"] = actual["base16"]
    return output


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="rewrite fixtures after explicit review")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    fixture_dir = repo / "tests" / "golden"
    changed = False
    for name, (provider, variant, accent) in FIXTURES.items():
        path = fixture_dir / f"{name}.json"
        current = json.loads(path.read_text())
        actual = expected(evaluate(repo, provider, variant, accent), current)
        if actual != current:
            changed = True
            if args.write:
                path.write_text(json.dumps(actual, indent=2) + "\n")
                print(f"updated {path.relative_to(repo)}")
            else:
                print(f"stale {path.relative_to(repo)}")
    if changed and not args.write:
        print("run `python3 scripts/update-golden.py --write` after reviewing the diff")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
