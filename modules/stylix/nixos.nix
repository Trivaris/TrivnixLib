{ pkgs, config, lib, ... }:
{
  options.hostPrefs.stylix = import ./options.nix lib;
  config.stylix = import ./config.nix config.hostPrefs pkgs;
}
