{ lib, config, ... }:
let
  inherit (lib) mkOption types;

  readTree =
    path:
    let
      entries = builtins.readDir path;
    in
    lib.mapAttrs (
      name: type: if type == "directory" then readTree (path + "/${name}") else path + "/${name}"
    ) entries;

  keyType = types.path;

  keyOption = mkOption {
    type = keyType;
    description = "Path to the public key file";
    readOnly = true;
  };

  commonSubmodule = types.submodule {
    options = {
      ssh = mkOption {
        type = types.attrsOf keyType;
        description = "Common SSH keys";
        default = { };
      };
    };
    freeformType = types.attrsOf (types.attrsOf keyType);
  };

  hostSubmodule = types.submodule {
    options = {
      "host.pub" = keyOption;

      users = mkOption {
        description = "User keys for this host";
        default = { };
        type = types.attrsOf (types.attrsOf keyType);
      };
    };
  };

  rawTree = readTree ./pubKeys;
in
{
  options.private.pubKeys = {
    common = mkOption {
      type = commonSubmodule;
      default = { };
    };

    hosts = mkOption {
      type = types.attrsOf hostSubmodule;
      default = { };
    };
  };

  config.private.pubKeys = {
    common = rawTree.common or { };
    hosts = rawTree.hosts or { };
  };
}
