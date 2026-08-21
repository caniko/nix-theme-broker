{
  lib,
  pkgs,
  selected,
  target,
}: let
  version = "1.0.0";
  id = "lmfonlemcgahfkfdalcnjgjibaiinhna";
  rgb = color:
    with color.rgb; [r g b];
  inherit (selected.roles) ui;
  manifest = pkgs.writeTextDir "manifest.json" (builtins.toJSON {
    manifest_version = 3;
    name = "Gruvbox Dark Hard";
    inherit version;
    theme.colors = {
      background_tab = rgb ui.background;
      background_tab_inactive = rgb ui.background;
      background_tab_incognito = rgb ui.background;
      background_tab_incognito_inactive = rgb ui.background;
      bookmark_text = rgb ui.foreground;
      button_background = rgb ui.backgroundAlt;
      frame = rgb ui.background;
      frame_inactive = rgb ui.backgroundAlt;
      frame_incognito = rgb ui.background;
      frame_incognito_inactive = rgb ui.backgroundAlt;
      ntp_background = rgb ui.background;
      ntp_header = rgb ui.backgroundAlt;
      ntp_link = rgb ui.link;
      ntp_text = rgb ui.foreground;
      omnibox_background = rgb ui.backgroundAlt;
      omnibox_text = rgb ui.foreground;
      tab_background_text = rgb ui.foregroundMuted;
      tab_background_text_inactive = rgb ui.foregroundMuted;
      tab_background_text_incognito = rgb ui.foregroundMuted;
      tab_background_text_incognito_inactive = rgb ui.foregroundMuted;
      tab_text = rgb ui.foreground;
      toolbar = rgb ui.backgroundAlt;
      toolbar_button_icon = rgb ui.foreground;
      toolbar_text = rgb ui.foreground;
    };
  });
  crx = pkgs.runCommand "gruvbox-browser-theme-${version}.crx" {nativeBuildInputs = [pkgs.go-crx3];} ''
    crx3 pack ${manifest} --pem ${./chromium.pem} --outfile "$out"
  '';
in {
  programs.${target}.extensions = lib.mkAfter [
    {
      inherit id version;
      crxPath = crx;
    }
  ];
}
