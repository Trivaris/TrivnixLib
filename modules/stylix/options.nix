{
  config,
  pkgs,
  lib,
  ...
}:
let
  prefs = config.stylixPrefs;
in
{
  options.stylixPrefs = {
    darkmode = lib.mkEnableOption ''
      Enable the dark Stylix palette for this system.
      When true, Stylix renders themes using the dark color variant.
    '';

    colorscheme = lib.mkOption {
      type = lib.types.str;
      example = "tokyo-night-dark";
      description = ''
        Base16 color scheme name applied across Stylix-managed themes.
        Provide the scheme filename without `.yaml`; it decides the palette source.
      '';
    };

    theme = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.base16-schemes}/share/themes/${prefs.colorscheme}.yaml";
      description = ''
        Path to a custom Base16 theme YAML file to be used by Stylix.
        If set, this overrides the `colorscheme` option.
      '';
    };

    cursorPackage = lib.mkOption {
      type = lib.types.str;
      example = "catppuccin-cursors";
      description = ''
        Package attribute providing the cursor theme pulled in by Stylix.
        It is looked up under `pkgs.<name>` when building your configuration.
      '';
    };

    cursorName = lib.mkOption {
      type = lib.types.str;
      example = "Catppuccin-Mocha-Dark-Cursors";
      description = ''
        Internal theme name Stylix selects from the chosen cursor package.
        Match it to one of the themes exposed by the package to avoid build errors.
      '';
    };

    cursorSize = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = ''
        Pixel size for the cursor when Stylix applies the theme.
        Impacts pointer scaling across X11 and Wayland desktops.
      '';
    };

    nerdfont = lib.mkOption {
      type = lib.types.str;
      example = "ubuntu";
      description = ''
        Nerd Font base name used for monospace, sans-serif, and serif fonts.
        Stylix resolves this to `pkgs.nerdfonts.<name>` when rendering fonts.
      '';
    };
  };
}
