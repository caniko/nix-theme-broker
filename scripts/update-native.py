#!/usr/bin/env python3
"""Regenerate the Catppuccin native target manifest from an explicit checkout."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path, help="realized catppuccin/nix checkout")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    output = args.output or repo / "native/catppuccin/manifest.nix"
    subprocess.run(
        [
            sys.executable,
            str(repo / "native/catppuccin/generate-manifest.py"),
            str(args.source),
            "--output",
            str(output),
        ],
        check=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
