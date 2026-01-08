{ pkgs, config, ... }:
{
  config.stylix = import ./config.nix config.userPrefs pkgs;
}
