{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { ... }@inputs: let
  libExtra = {
    mkFlakePath = self: path: self + (toString path);
    resolveDir = import ./resolveDir.nix {inherit inputs; inherit (libExtra) mkFlakePath; };

    pkgsConfig = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      android_sdk.accept_license = true;
      permittedInsecurePackages = [
        "libsoup-2.74.3"
      ];
    };
  };
  in libExtra;
}
