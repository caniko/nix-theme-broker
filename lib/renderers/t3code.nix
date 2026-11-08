{lib}: selected: let
  inherit (selected.roles) ui status;
  hex = color: color.withHashtag;
  # T3 Code trims names and caps them at 48 characters.
  name = let
    trimmed = lib.trim (lib.substring 0 48 (
      if selected.accent == null
      then selected.formatted.base16Scheme.scheme
      else "${selected.formatted.base16Scheme.scheme} (${selected.accent})"
    ));
  in
    if trimmed == ""
    then "Theme Broker"
    else trimmed;
in {
  version = 1;
  inherit name;
  appearance = selected.metadata.appearance;
  canvas = hex ui.background;
  accent = hex ui.accent;
  colors = {
    canvas = hex ui.background;
    surface = hex ui.surface;
    surfaceRaised = hex ui.surfaceAlt;
    surfaceOverlay = hex ui.overlay;
    text = hex ui.foreground;
    textMuted = hex ui.foregroundMuted;
    border = hex ui.border;
    focus = hex ui.focus;
    accent = hex ui.accent;
    error = hex status.error;
    warning = hex status.warning;
    codeBackground = hex ui.surface;
    codeForeground = hex ui.foreground;
    terminalBackground = hex ui.background;
    terminalForeground = hex ui.foreground;
    terminalCursor = hex ui.accent;
    terminalSelection = hex ui.selectionBackground;
  };
}
