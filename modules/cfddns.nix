{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.services.cfddns;
in
{
  options.services.cfddns = {
    enable = mkEnableOption "Enable the CFDDNS Middleware service";
    port = mkOption {
      type = types.port;
      default = 80;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cfddns = {
      description = "Cloudflare Dyn DNS Middleware Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.cfddns-middleware} --port ${toString cfg.port}";
        Restart = "on-failure";
      };
    };
  };
}