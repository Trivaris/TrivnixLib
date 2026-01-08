prefs: pkgs: {
  darkmode = pkgs.lib.mkEnableOption ''
    Enable the dark Stylix palette for this system.
    When true, Stylix renders themes using the dark color variant.
  '';

  colorscheme = pkgs.lib.mkOption {
    type = pkgs.lib.types.str;
    example = "tokyo-night-dark";
    description = ''
      Base16 color scheme name applied across Stylix-managed themes.
      Provide the scheme filename without `.yaml`; it decides the palette source.
    '';
  };

  theme = pkgs.lib.mkOption {
    type = pkgs.lib.types.str;
    default = "${pkgs.base16-schemes}/share/themes/${prefs.stylix.colorscheme}.yaml";
    description = ''
      Path to a custom Base16 theme YAML file to be used by Stylix.
      If set, this overrides the `colorscheme` option.
    '';
  };

  cursorPackage = pkgs.lib.mkOption {
    type = pkgs.lib.types.str;
    example = "catppuccin-cursors";
    description = ''
      Package attribute providing the cursor theme pulled in by Stylix.
      It is looked up under `pkgs.<name>` when building your configuration.
    '';
  };

  cursorName = pkgs.lib.mkOption {
    type = pkgs.lib.types.str;
    example = "Catppuccin-Mocha-Dark-Cursors";
    description = ''
      Internal theme name Stylix selects from the chosen cursor package.
      Match it to one of the themes exposed by the package to avoid build errors.
    '';
  };

  cursorSize = pkgs.lib.mkOption {
    type = pkgs.lib.types.int;
    default = 24;
    description = ''
      Pixel size for the cursor when Stylix applies the theme.
      Impacts pointer scaling across X11 and Wayland desktops.
    '';
  };

  nerdfont = pkgs.lib.mkOption {
    type = pkgs.lib.types.str;
    example = "ubuntu";
    description = ''
      Nerd Font base name used for monospace, sans-serif, and serif fonts.
      Stylix resolves this to `pkgs.nerdfonts.<name>` when rendering fonts.
    '';
  };
}
