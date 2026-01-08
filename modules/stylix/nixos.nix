{ pkgs, config, ... }:
{
  options.hostPrefs.stylix = import ./options.nix config.hostPrefs pkgs;
  config.stylix = import ./config.nix config.hostPrefs pkgs;
}
