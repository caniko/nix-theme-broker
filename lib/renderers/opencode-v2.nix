{lib}: selected: let
  inherit (selected.roles) ui status syntax;
  hex = color: color.withHashtag;
  # Integer sRGB interpolation is deterministic at evaluation time. Semantic
  # colors stay exact; only required hue steps and tinted fills are interpolated.
  mix = from: to: weight: let
    byte = channel:
      lib.fixedWidthString 2 "0" (lib.toLower (lib.toHexString
          (builtins.div (from.rgb.${channel} * (100 - weight) + to.rgb.${channel} * weight + 50) 100)));
  in "#${byte "r"}${byte "g"}${byte "b"}";
  dark = selected.metadata.appearance == "dark";
  contrast = {
    rgb = lib.genAttrs ["r" "g" "b"] (_:
      if dark
      then 255
      else 0);
  };
  scale = color:
    lib.listToAttrs (map (step: {
      name = toString step;
      value =
        if step == 100
        then mix color contrast 25
        else if step == 200
        then hex color
        else mix color ui.background (builtins.div ((step - 200) * 100) 700);
    }) [100 200 300 400 500 600 700 800 900]);
  hue = lib.mapAttrs (_: scale) {
    gray = ui.foreground;
    red = status.error;
    orange = selected.base16.base09;
    yellow = status.warning;
    green = status.success;
    cyan = selected.ansi.normal.cyan;
    blue = status.info;
    purple = selected.ansi.normal.magenta;
    accent = ui.accent;
    interactive = ui.accent;
    neutral = ui.foreground;
  };
  textAction = color: {
    base = hex color;
    "$hovered" = hex ui.accent;
    "$focused" = hex ui.background;
    "$pressed" = hex ui.background;
    "$selected" = "$text.base";
    "$disabled" = "$text.muted";
  };
  backgroundAction = color: {
    base = "transparent";
    "$hovered" = "$background.raised.base";
    "$focused" = hex color;
    "$pressed" = hex color;
    "$selected" = "$hue.interactive.700";
    "$disabled" = "transparent";
  };
  feedbackText = lib.mapAttrs (_: color: {base = hex color;}) {
    inherit (status) error warning success info;
  };
  feedbackBackground = lib.mapAttrs (_: color: {base = mix ui.background color 12;}) {
    inherit (status) error warning success info;
  };
  added = mix ui.background status.success 12;
  removed = mix ui.background status.error 12;
in {
  "$schema" = "https://opencode.ai/theme.json";
  ${selected.metadata.appearance} = {inherit hue;};
  base = {
    categorical = ["accent" "purple" "green" "blue" "orange" "cyan" "red" "yellow"];
    text = {
      base = hex ui.foreground;
      muted = hex ui.foregroundMuted;
      action = {
        primary = textAction ui.foreground;
        secondary = textAction ui.foregroundMuted;
        destructive = (textAction status.error) // {"$hovered" = hex status.error;};
      };
      formfield = {
        base = "$text.base";
        "$hovered" = "$text.base";
        "$focused" = "$text.base";
        "$pressed" = "$text.base";
        "$selected" = hex ui.selectionForeground;
        "$disabled" = "$text.muted";
      };
      feedback = feedbackText;
    };
    background = {
      base = hex ui.background;
      raised = {
        base = hex ui.surface;
        high = hex ui.surfaceAlt;
        max = hex ui.overlay;
      };
      action = {
        primary = backgroundAction ui.accent;
        secondary = backgroundAction ui.accent;
        destructive = (backgroundAction status.error) // {"$selected" = removed;};
      };
      formfield = {
        base = "$background.base";
        "$hovered" = "$background.raised.base";
        "$focused" = "$background.raised.base";
        "$pressed" = "$background.raised.high";
        "$selected" = hex ui.selectionBackground;
        "$disabled" = "$background.base";
      };
      feedback = feedbackBackground;
    };
    border.base = hex ui.border;
    scrollbar.base = hex ui.focus;
    diff = {
      text = {
        added = hex status.success;
        removed = hex status.error;
        context = hex ui.foreground;
        hunkHeader = hex ui.accent;
      };
      background = {
        inherit added removed;
        context = "$background.base";
      };
      highlight = {
        added = mix ui.background status.success 25;
        removed = mix ui.background status.error 25;
      };
      lineNumber = {
        text = hex ui.foregroundMuted;
        background = {inherit added removed;};
      };
    };
    syntax =
      lib.genAttrs ["comment" "keyword" "function" "variable" "string" "number" "type" "operator" "punctuation"]
      (key: hex syntax.${key});
    markdown = {
      text = hex ui.foreground;
      heading = hex ui.accent;
      link = hex ui.link;
      linkText = hex ui.link;
      code = hex syntax.string;
      blockQuote = hex ui.foregroundMuted;
      emphasis = hex syntax.keyword;
      strong = hex ui.foreground;
      horizontalRule = hex ui.border;
      listItem = hex ui.accent;
      listEnumeration = hex syntax.number;
      image = hex ui.link;
      imageText = hex ui.foregroundMuted;
      codeBlock = hex ui.foreground;
    };
    "@dialog".background = {
      base = "$background.raised.base";
      action.primary."$hovered" = "$background.raised.high";
    };
  };
}
