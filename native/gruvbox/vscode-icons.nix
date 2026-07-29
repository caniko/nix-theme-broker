{lib, pkgs}:
pkgs.vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    publisher = "navernoedenis";
    name = "gruvbox-material-icons";
    version = "4.6.0";
    hash = "sha256-uenAqUlBvigqxEqNgM44wvL/c5Jb2lDzSEGfMiNKrpQ=";
  };
  meta = {
    description = "Gruvbox-style icons for VS Code";
    homepage = "https://github.com/navernoedenis/gruvbox-material-icons";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=navernoedenis.gruvbox-material-icons";
    license = lib.licenses.mit;
  };
}
