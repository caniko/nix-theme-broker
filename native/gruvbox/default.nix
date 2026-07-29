{
  vim = {
    id = "gruvbox-vim";
    provider = "gruvbox";
    target = "vim";
    tier = "canonical";
    repository = "https://github.com/morhetz/gruvbox";
    revision = "5d15b2765f59754d7ac263c88a0f6e3e58124951";
  };
  neovim = {
    id = "gruvbox-neovim";
    provider = "gruvbox";
    target = "neovim";
    tier = "maintained";
    repository = "https://github.com/ellisonleao/gruvbox.nvim";
    revision = "154eb5ff5b96d0641307113fa385eaf0d36d9796";
  };
}
