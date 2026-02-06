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
      default = builtins.fromJSON (builtins.readFile (pkgs.runCommand "load-scheme" {
        nativeBuildInputs = [ pkgs.yq pkgs.base16-schemes ];
      } "yq '.palette' ${pkgs.base16-schemes}/share/themes/${prefs.schemeName}.yaml > $out" ));
    };

    schemeName = lib.mkOption {
      type = lib.types.str;
    };

    themeOverrides = lib.mkOption {
      type = lib.types.submodule {
        options = {
          spicetify = lib.mkOption {
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                package = lib.mkOption {
                  type = lib.types.nullOr lib.types.attrs;
                  default = pkgs.spicePkgs.themes.catppuccin;
                };
                scheme = lib.mkOption {
                  type = lib.types.str;
                  default = "mocha";
                };
              };
            });
            example = {
              package = pkgs.spicePkgs.themes.catppuccin;
              scheme = "mocha";
            };
            default = null;
          };
          kitty = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            example = "${pkgs.kitty-themes}/share/kitty-themes/themes/Catppuccin-Mocha.conf";
            default = null;
          };
        };
      };
      default = {
        spicetify = null;
        kitty = null;
      };
    };

    font = lib.mkOption {
      type = lib.types.submodule {
        options = {
          package = lib.mkPackageOption pkgs "Font" {
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