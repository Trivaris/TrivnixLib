{ lib, ... }:
{
  options.userPrefs.stylix = import ./options.nix lib;
}
