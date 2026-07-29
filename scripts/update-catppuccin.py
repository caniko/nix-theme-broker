#!/usr/bin/env python3
"""Validate an explicit Catppuccin palette and refresh reviewed goldens."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("palette", type=Path, help="realized catppuccin/palette checkout")
    parser.add_argument("--write-golden", action="store_true")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    subprocess.run([sys.executable, str(repo / "providers/catppuccin/update.py"), str(args.palette)], check=True)
    if args.write_golden:
        subprocess.run([sys.executable, str(repo / "scripts/update-golden.py"), "--write"], check=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
