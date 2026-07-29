{inputs, ...}: {
  imports = [inputs.theme-broker.homeModules.default];
  themeBroker = {
    enable = true;
    selection = {
      provider = "catppuccin";
      variant = "mocha";
      accent = "mauve";
    };
    targets.alacritty.backend = "native";
  };
}
