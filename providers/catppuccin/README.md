# Catppuccin provider maintenance

Evaluation reads the locked `catppuccin/palette` input directly. Validate an
explicit checkout before changing the pin:

```console
python3 providers/catppuccin/update.py /path/to/catppuccin-palette
```

The updater never runs during Nix evaluation or builds. Review variant,
accent, and golden-output diffs before accepting a palette update.
