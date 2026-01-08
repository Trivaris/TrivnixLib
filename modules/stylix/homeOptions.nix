{ pkgs, config, ... }:
{
  options.userPrefs.stylix = import ./options.nix config.userPrefs pkgs;
}
