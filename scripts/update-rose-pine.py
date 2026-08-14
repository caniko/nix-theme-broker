#!/usr/bin/env python3
"""Validate an explicit Rosé Pine palette checkout."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path, help="rose-pine/rose-pine-palette checkout")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    subprocess.run(
        [sys.executable, str(repo / "providers/rose-pine/update.py"), str(args.source)],
        check=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
