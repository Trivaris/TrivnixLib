{ lib, ... }:
{
  options.hostPrefs.stylix = import ./stylixOptions.nix lib;
}
