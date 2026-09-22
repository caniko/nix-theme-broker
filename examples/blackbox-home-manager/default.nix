{inputs, ...}: {
  imports = [inputs.theme-broker.homeModules.default];
  themeBroker = {
    enable = true;
    selection = {
      provider = "blackbox";
      variant = "dark";
      accent = null;
    };
  };
}
