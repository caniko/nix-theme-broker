{inputs, ...}: {
  imports = [inputs.theme-broker.homeModules.default];
  themeBroker = {
    enable = true;
    selection = {
      provider = "gruvbox";
      variant = "dark-medium";
      accent = null;
    };
    targets = {
      neovim.backend = "native";
      alacritty.backend = "generated";
    };
  };
}
