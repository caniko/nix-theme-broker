{lib}: let
  types = import ./types.nix {inherit lib;};
in {
  inherit (types) base16Keys ansiKeys;
  validateExact = provider: variant: path: value: keys: let
    actual = lib.attrNames value;
    missing = lib.subtractLists keys actual;
    extra = lib.subtractLists actual keys;
  in
    if missing == [] && extra == []
    then true
    else throw "themeBroker: provider `${provider}` variant `${variant}` at `${lib.concatStringsSep "." path}`: expected exactly ${lib.concatStringsSep "," keys}, got ${lib.concatStringsSep "," actual}";
}
