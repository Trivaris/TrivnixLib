{
  mkOption,
  types,
  mkEnableOption,
}:
{ defaultPort }:
mkOption {
  type = types.submodule {
    options = {
      enable = mkEnableOption "Wether to enable to Reverseproxy";

      port = mkOption {
        type = types.int;
        default = defaultPort;
        description = "Internal service port.";
      };

      domain = mkOption {
        type = types.str;
        example = "service.example.com";
        description = "Domain for the service.";
      };

      externalPort = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "Optional external port for the service.";
      };

      ipAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = ''
          Internal IP address the service binds to.
          Use "127.0.0.1" for localhost-only access or "0.0.0.0" to listen on all interfaces.
        '';
      };
    };
  };
  default = {
    enable = false;
    port = defaultPort;
    domain = "";
    externalPort = null;
    ipAddress = "127.0.0.1";
  };
  description = "List of services with name, ports, and domain.";
}
