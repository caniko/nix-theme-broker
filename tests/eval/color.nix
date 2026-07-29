{lib}: let
  color = (import ../../lib {inherit lib;}).color;
  parsed = color.parse "#1D2021";
  invalid = builtins.tryEval (color.parse "#12345");
in
  assert parsed.hex == "1d2021";
  assert parsed.withHashtag == "#1d2021";
  assert parsed.with0x == "0x1d2021";
  assert parsed.rgb
  == {
    r = 29;
    g = 32;
    b = 33;
  };
  assert !invalid.success; true
