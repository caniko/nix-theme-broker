{lib}: let
  pathText = path: lib.concatStringsSep "." path;
in {
  inherit pathText;
  error = provider: variant: path: message:
    throw "themeBroker: provider `${provider}` variant `${variant}` at `${pathText path}`: ${message}";
  require = provider: variant: path: condition: message:
    if condition
    then true
    else throw "themeBroker: provider `${provider}` variant `${variant}` at `${pathText path}`: ${message}";
}
