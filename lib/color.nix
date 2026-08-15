{lib}: let
  parse = value: let
    raw =
      if builtins.isAttrs value && value ? hex
      then value.hex
      else value;
  in
    if !builtins.isString raw
    then throw "themeBroker: expected a six-digit hexadecimal color, got ${toString raw}"
    else let
      matches = builtins.match "#?([0-9A-Fa-f]{6})" raw;
    in
      if matches == null
      then throw "themeBroker: expected a six-digit hexadecimal color, got ${raw}"
      else let
        hex = lib.toLower (builtins.head matches);
        byte = offset: lib.fromHexString (lib.substring offset 2 hex);
      in {
        inherit hex;
        withHashtag = "#${hex}";
        with0x = "0x${hex}";
        rgb = {
          r = byte 0;
          g = byte 2;
          b = byte 4;
        };
        hsl =
          if builtins.isAttrs value && value ? hsl
          then value.hsl
          else null;
        oklch =
          if builtins.isAttrs value && value ? oklch
          then value.oklch
          else null;
        sourceName = let
          value' =
            if builtins.isAttrs value && value ? sourceName
            then value.sourceName
            else null;
        in
          if value' == null || builtins.isString value'
          then value'
          else throw "themeBroker: sourceName must be a string or null, got ${builtins.toJSON value'}";
      };
in {
  inherit parse;
}
