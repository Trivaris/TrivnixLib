{ lib, ... }:
let 
  keyCollectionType = lib.types.submodule {
    options = {
      key = lib.mkOption { type = lib.types.path; };
      id = lib.mkOption { type = lib.types.int; };
    };
  };
in 
{
  options.private.wgPeers = {
    guests = lib.mkOption {
      type = lib.types.attrsOf keyCollectionType;
    };
    hosts = lib.mkOption {
      type = lib.types.attrsOf keyCollectionType;
    };
  };
}