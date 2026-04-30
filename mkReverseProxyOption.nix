{
  mkOption,
  types,
  mkEnableOption,
  ...
}:
{ defaultPort }:
mkOption {
  description = "List of services with name, ports, and domain.";

  type = types.submodule {
    options = {
      enable = mkEnableOption "Wether to enable to Reverseproxy";

      port = mkOption {
        type = types.port;
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
        description = "Optional external port for the service. Only used if reverse Proxy is enabled, otherwise config.port is used";
      };
    };
  };
  
  default = {
    enable = false;
    port = defaultPort;
    external = null;
  };
}
