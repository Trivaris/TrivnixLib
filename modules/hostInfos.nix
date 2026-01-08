{
  lib,
  ...
}:
let
  mkStrOption =
    desc:
    lib.mkOption {
      type = lib.types.str;
      description = desc;
    };
in
{
  options.hostInfos = {
    name = mkStrOption "The name of the host.";
    configname = mkStrOption "The configuration name of the host.";
    stateVersion = mkStrOption "The NixOS state version for this host.";
    ip = mkStrOption "The static IP address assigned to this host.";
    architecture = mkStrOption "The system architecture of this host.";
    hashedRootPassword = mkStrOption "The hashed root password for this host.";
    primaryMonitor = mkStrOption "The primary monitor identifier for this host.";
    monitors = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            resolution = mkStrOption "The resolution of the monitor.";
            refreshRate = mkStrOption "The refresh rate of the monitor.";
            position = mkStrOption "The position of the monitor in the layout.";
            scaling = mkStrOption "The scaling factor for the monitor.";
            wallpaper = lib.mkOption {
              type = lib.types.path;
              description = "The wallpaper path for the monitor.";
            };
          };
        }
      );
    };
  };
}
