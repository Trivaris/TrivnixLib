prefs: pkgs: {
  enable = true;
  base16Scheme = prefs.stylix.theme;
  polarity = if prefs.stylix.darkmode then "dark" else "light";
  targets.gtk.enable = true;

  cursor = {
    package = pkgs.${prefs.stylix.cursorPackage};
    name = prefs.stylix.cursorName;
    size = prefs.stylix.cursorSize;
  };

  fonts = {
    serif = {
      name = prefs.stylix.nerdfont;
      package = pkgs.nerd-fonts.${prefs.stylix.nerdfont};
    };

    monospace = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
    };

    sansSerif = {
      name = prefs.stylix.nerdfont;
      package = pkgs.nerd-fonts.${prefs.stylix.nerdfont};
    };
  };
}
