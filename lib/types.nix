{lib}: {
  base16Keys = [
    "base00"
    "base01"
    "base02"
    "base03"
    "base04"
    "base05"
    "base06"
    "base07"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
    "base0F"
  ];
  ansiKeys = ["black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"];
  requiredRoles = [
    ["ui" "background"]
    ["ui" "backgroundAlt"]
    ["ui" "surface"]
    ["ui" "surfaceAlt"]
    ["ui" "overlay"]
    ["ui" "foreground"]
    ["ui" "foregroundMuted"]
    ["ui" "border"]
    ["ui" "selectionBackground"]
    ["ui" "selectionForeground"]
    ["ui" "focus"]
    ["ui" "accent"]
    ["ui" "link"]
    ["status" "error"]
    ["status" "warning"]
    ["status" "success"]
    ["status" "info"]
    ["status" "hint"]
    ["syntax" "comment"]
    ["syntax" "string"]
    ["syntax" "number"]
    ["syntax" "boolean"]
    ["syntax" "keyword"]
    ["syntax" "function"]
    ["syntax" "type"]
    ["syntax" "variable"]
    ["syntax" "constant"]
    ["syntax" "operator"]
    ["syntax" "punctuation"]
    ["syntax" "tag"]
    ["syntax" "attribute"]
  ];
  # Optional `roles.figure` group (scientific figures and web charts). Colour
  # keys take hex or `@name` references; `figureDataKeys` carry plain data.
  figureColorKeys = [
    "background"
    "surface"
    "surface_alt"
    "border"
    "ink"
    "muted"
    "link"
    "accent"
    "positive"
    "negative"
    "highlight"
    "on_status"
    "true_mask"
    "false_mask"
    "unavailable"
    "point"
    "box_fill"
    "reference"
    "categorical"
  ];
  figureDataKeys = ["sequential_cmap" "density_cmap" "time_cmap" "time_range"];
}
