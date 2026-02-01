{
  lib,
  pkgs,
  config,
  ...
}:
let 
  prefs = config.themingPrefs;
in 
{
  options.themingPrefs = {
    darkmode = lib.mkEnableOption "Enable Dark Mode";
    
    scheme = lib.mkOption {
      type = lib.types.attrsOf (lib.types.strMatching "^#[a-f|A-F|0-9]{6,6}$");
      description = "";
      default = builtins.fromJSON (builtins.readFile (pkgs.runCommand "load-scheme" {
        nativeBuildInputs = [ pkgs.yq pkgs.base16-schemes ];
      } "yq '.palette' ${pkgs.base16-schemes}/share/themes/${prefs.schemes.general}.yaml > $out" ));
    };

    themes = lib.mkOption {
      type = lib.types.submodule {
        options = {
          spicetify = lib.mkPackageOption pkgs "SpicetifyTheme" {
            default = [ "spicePkgs" "themes" "catppuccin" ];
          };
        };
      };
    };

    schemes = lib.mkOption {
      type = lib.types.submodule {
        options = {
          general = lib.mkOption {
            type = lib.types.str;
            default = "catppuccin-mocha";
          };

          kitty = lib.mkOption {
            type = lib.types.str;
            default = "Catppuccin-Mocha";
          };

          spicetify = lib.mkOption {
            type = lib.types.str;
            default = "mocha";
          };
        };
      };
      default = {
        general = "catppuccin-mocha";
        kitty = "Catppuccin-Mocha";
        spicetify = "mocha";
      };
    };

    cursor = lib.mkOption {
      type = lib.types.submodule {
        options = {
          package = lib.mkPackageOption pkgs "Cursors" {
            default = [ "rose-pine-cursor" ];
          };

          name = lib.mkOption {
            type = lib.types.str;
            default = "BreezeX-RosePine-Linux";
          };
        };
      };
      default = {
        package = pkgs.rose-pine-cursor;
        name = "BreezeX-RosePine-Linux";
      };
    };

    font = lib.mkOption {
      type = lib.types.submodule {
        options = {
          package = lib.mkPackageOption pkgs "SpicetifyTheme" {
            default = [ "nerd-fonts" "jetbrains-mono" ];
          };

          name = lib.mkOption {
            type = lib.types.str;
            default = "JetBrains Mono";
          };
        };
      };
      default = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono";
      };
    };
  };
}