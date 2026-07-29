{
  lib,
  pkgs,
  selected,
}: {
  programs.vim.plugins = lib.mkAfter [pkgs.vimPlugins.gruvbox];
  programs.vim.extraConfig = ''
    set background=${selected.metadata.appearance}
    let g:gruvbox_contrast_${selected.metadata.appearance} = "${selected.metadata.contrast}"
    colorscheme gruvbox
  '';
}
