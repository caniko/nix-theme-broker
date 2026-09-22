#!/usr/bin/env python3
"""Regenerate or verify the reviewed normalized-theme golden fixtures."""

from __future__ import annotations

import argparse
import importlib.util
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


def refreshed_source(actual: dict, current: dict, upstream: dict, revision: str) -> dict:
    """Advance provenance only: changed colors still require explicit review."""
    if expected(actual, current) != current:
        raise ValueError("provider output changed; review the golden diff before updating")
    if current["source"]["repository"] != TINTED_SOURCE["repository"]:
        raise ValueError("unexpected golden source repository")
    if current["base16"] != upstream:
        raise ValueError("pinned Tinted colors changed; provenance cannot be advanced automatically")
    if len(revision) != 40 or any(c not in "0123456789abcdef" for c in revision):
        raise ValueError("expected a full pinned source revision")
    return current | {"source": current["source"] | {"revision": revision}}


def main() -> int:
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--write", action="store_true", help="rewrite fixtures after explicit review")
    mode.add_argument("--refresh-source", action="store_true", help="advance provenance only if provider output and pinned upstream colors still match")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    fixture_dir = repo / "tests" / "golden"
    source = None
    if args.refresh_source:
        expression = f"let f = builtins.getFlake {nix_string(str(repo))}; in {{ path = toString f.inputs.tinted-schemes; revision = f.inputs.tinted-schemes.rev; }}"
        result = subprocess.run(
            ["nix", "eval", "--no-allow-import-from-derivation", "--impure", "--no-update-lock-file", "--json", "--expr", expression],
            check=True, capture_output=True, text=True,
        )
        source = json.loads(result.stdout)
        spec = importlib.util.spec_from_file_location("check_tinted", repo / "scripts" / "check-tinted.py")
        checker = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(checker)
    changed = False
    updates = []
    for name, (provider, variant, accent) in FIXTURES.items():
        path = fixture_dir / f"{name}.json"
        current = json.loads(path.read_text())
        observed = evaluate(repo, provider, variant, accent)
        if source is not None:
            scheme = current["source"]["scheme"]
            if not scheme or any(c not in "abcdefghijklmnopqrstuvwxyz0123456789-" for c in scheme):
                raise ValueError("invalid Tinted scheme name")
            upstream = checker.read_scheme(Path(source["path"]) / "base16" / f"{scheme}.yaml")
            actual = refreshed_source(observed, current, upstream, source["revision"])
        else:
            actual = expected(observed, current)
        if actual != current:
            changed = True
            if args.write or args.refresh_source:
                updates.append((path, actual))
            else:
                print(f"stale {path.relative_to(repo)}")
    # Validate every fixture before writing any of them.
    for path, actual in updates:
        path.write_text(json.dumps(actual, indent=2) + "\n")
        print(f"updated {path.relative_to(repo)}")
    if changed and not (args.write or args.refresh_source):
        print("run `python3 scripts/update-golden.py --write` after reviewing the diff")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
