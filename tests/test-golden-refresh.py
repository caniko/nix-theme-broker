#!/usr/bin/env python3
"""The unattended refresh may advance provenance, never expected colors."""
import copy
import importlib.util
import json
import sys
from pathlib import Path

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("update_golden", root / "scripts/update-golden.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
current = json.loads((root / "tests/golden/gruvbox-dark-medium.json").read_text())
actual = {key: current[key] for key in ["provider", "variant", "accent", "background", "base16"]}
actual["accentColor"] = None
revision = "a" * 40
result = module.refreshed_source(actual, current, current["base16"], revision)
assert result == current | {"source": current["source"] | {"revision": revision}}
assert current["source"]["revision"] != revision
for changed_actual, changed_upstream in [
    (actual | {"background": "#000000"}, current["base16"]),
    (actual, current["base16"] | {"base00": "#000000"}),
]:
    before = copy.deepcopy(current)
    try:
        module.refreshed_source(changed_actual, current, changed_upstream, revision)
    except ValueError:
        pass
    else:
        raise AssertionError("unreviewed color changes must fail")
    assert current == before
print("golden provenance refresh checks passed")
