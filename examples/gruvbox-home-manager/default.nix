{inputs, ...}: {
  imports = [inputs.theme-broker.homeModules.default];
  themeBroker = {
    enable = true;
    selection = {
      provider = "gruvbox";
      variant = "dark-hard";
      accent = null;
    };
  };
}
