{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, ... }@inputs:
  let
    makeLib = selfArg:
      let
        mkFlakePath = path: selfArg + (toString path);

        libExtra = {
          inherit mkFlakePath;

          resolveDir = import ./resolveDir.nix {
            inherit inputs mkFlakePath;
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
