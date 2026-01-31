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

    themeName = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-mocha";
    };

    kittyTheme = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-mocha";
    };

    theme = lib.mkOption {
      type = lib.types.attrsOf (lib.types.strMatching "^#[a-f|A-F|0-9]{6,6}$");
      description = "";
      default = builtins.fromJSON (builtins.readFile (pkgs.runCommand "load-scheme" {
        nativeBuildInputs = [ pkgs.yq pkgs.base16-schemes ];
      } "yq '.palette' ${pkgs.base16-schemes}/share/themes/${prefs.themeName}.yaml > $out" ));
    };

    font = lib.mkOption {
      type = lib.types.functionTo lib.types.package;
      default = optPkgs: optPkgs.nerd-fonts.jetbrains-mono;
    };

    cursorPackage = lib.mkOption {
      type = lib.types.functionTo lib.types.package;
      default = optPkgs: optPkgs.rose-pine-cursor;
    };

    cursorName = lib.mkOption {
      type = lib.types.str;
      default = "BreezeX-RosePine-Linux";
    };
  };
}