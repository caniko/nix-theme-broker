{
  lib,
  pkgs,
  selected,
  transparent ? false,
}: {
  programs.neovim.plugins = lib.mkAfter [pkgs.vimPlugins.gruvbox-nvim];
  programs.neovim.extraLuaConfig = ''
    vim.o.background = "${selected.metadata.appearance}"
    local ok, gruvbox = pcall(require, "gruvbox")
    if ok then
      gruvbox.setup({
        contrast = "${
      if selected.metadata.contrast == "medium"
      then ""
      else selected.metadata.contrast
    }",
        transparent_mode = ${
      if transparent
      then "true"
      else "false"
    }
      })
      vim.cmd.colorscheme("gruvbox")
    end
  '';
}
