{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      makeLib =
        selfArg:
        let
          mkStorePath = path: selfArg + (toString "/${path}");
          mkFlakePath = path: lib.removePrefix (selfArg + "/") (toString path);

          getColor =
            { scheme, pkgs }:
            name:
            (pkgs.runCommand "color-${name}" {
              inherit scheme;
              nativeBuildInputs = [ pkgs.yq ];
            } "yq -r '.palette.${name}' \"${scheme}\" > $out")
            |> builtins.readFile
            |> builtins.replaceStrings [ "\n" ] [ "" ];

          recursiveAttrValues =
            attrs:
            attrs
            |> builtins.attrValues
            |> map (value: if lib.isAttrs value then recursiveAttrValues value else [ value ])
            |> builtins.concatLists;

          trivnixLib = {
            inherit
              mkStorePath
              mkFlakePath
              recursiveAttrValues
              getColor
              ;
            mkHomeManager = import ./mkHomeManager.nix selfArg;
            mkNixOS = import ./mkNixOS.nix selfArg;

            resolveDir = import ./resolveDir.nix {
              inherit inputs;
            };

            mkReverseProxyOption = import ./mkReverseProxyOption.nix {
              inherit (lib) types mkOption mkEnableOption;
            };
          };
        in
        trivnixLib;

      trivnixLib = makeLib self;
    in
    {
      lib = {
        default = makeLib self;
        for = makeLib;
      };

      tests = {
        imports = trivnixLib.resolveDir {
          dirPath = ./test/imports;
          preset = "importList";
        };
        modules = trivnixLib.resolveDir {
          dirPath = ./test/modules;
          preset = "moduleNames";
        };
      };
    };
}
