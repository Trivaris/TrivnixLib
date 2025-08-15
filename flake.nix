{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    makeLib = selfArg:
      let
        mkFlakePath = path: selfArg + (toString path);
        inherit (nixpkgs.lib) mkOption types mkEnableOption;

        libExtra = {
          inherit mkFlakePath;

          resolveDir = import ./resolveDir.nix {
            inherit inputs mkFlakePath;
          };

          mkReverseProxyOption = { defaultPort }:
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
              description = "List of services with name, ports, and domain.";
            };

          pkgsConfig = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
            android_sdk.accept_license = true;
            permittedInsecurePackages = [ "libsoup-2.74.3" ];
          };
        };
      in
        libExtra;
  in
  {
    lib.default = makeLib self;
    lib.for = makeLib;
  };
}
