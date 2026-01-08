{ config, pkgs, ... }:
let
  prefs = config.stylixPrefs;
in
{
  stylix = {
    enable = true;
    base16Scheme = prefs.theme;
    polarity = if prefs.darkmode then "dark" else "light";
    targets.gtk.enable = true;

    cursor = {
      package = pkgs.${prefs.cursorPackage};
      name = prefs.cursorName;
      size = prefs.cursorSize;
    };

    fonts = {
      serif = {
        name = prefs.nerdfont;
        package = pkgs.nerd-fonts.${prefs.nerdfont};
      };

      monospace = {
        name = "JetBrainsMono Nerd Font";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };

      sansSerif = {
        name = prefs.nerdfont;
        package = pkgs.nerd-fonts.${prefs.nerdfont};
      };
    };
  };
}
