{ lib, config, ... }:
{
  options.private.secrets = lib.mkOption {
    type = lib.types.path;
    description = "Path to the secrets directory.";
    readOnly = true;
  };
}
