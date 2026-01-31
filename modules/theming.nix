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
    themeName = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-frappe";
    };

    theme = lib.mkOption {
      type = lib.types.attrsOf lib.types.strMatching "^#[a-f|A-F|0-9]{6,6}$";
      description = "";
      default = builtins.fromJSON (builtins.readFile (pkgs.runCommand "load-scheme" {
          nativeBuildInputs = [ pkgs.yq pkgs.base16-schemes ];
        } "yq '.palette' ${pkgs.base16-schemes}/share/themes/${prefs.themeName}.yaml > $out" ));
    };

    font = lib.mkPackageOption pkgs "nerd-fonts-jetbrains-mono" {
      default = [ "nerd-fonts" "jetbrains-mono" ];
    };
  };
}