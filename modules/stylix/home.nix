{ lib, ... }:
{
  options.userPrefs.stylix = import ./stylixOptions.nix lib;
}
