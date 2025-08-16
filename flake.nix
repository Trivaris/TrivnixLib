{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    inherit (nixpkgs) lib;

    makeLib = selfArg: let
      mkStorePath = path: selfArg + (toString "/${path}");
      mkFlakePath = path: lib.removePrefix (selfArg + (toString "/")) (toString path);

      trivnixLib = {
        inherit mkStorePath mkFlakePath;

        resolveDir = import ./resolveDir.nix {
          inherit inputs mkFlakePath mkStorePath;
        };

        mkReverseProxyOption = import ./mkReverseProxyOption { inherit (lib) types mkOption mkEnableOption; };
        
        pkgsConfig = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
          android_sdk.accept_license = true;
          permittedInsecurePackages = [ "libsoup-2.74.3" ];
        };
      };
    in trivnixLib;

    trivnixLib = makeLib self;
  in {
    lib.default = makeLib self;
    lib.for = makeLib;
    test = trivnixLib.resolveDir {
      dirPath = ./test;
      depth = 3;
      mode = "imports";
      includeNonNix = true;
    };
  };
}
