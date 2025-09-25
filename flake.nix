{
  description = "Trivnix Helpers and Utilities";

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
            lib.pipe
              (pkgs.runCommand "color-${name}" {
                inherit scheme;
                nativeBuildInputs = [ pkgs.yq ];
              } "yq -r '.palette.${name}' \"${scheme}\" > $out")
              [
                builtins.readFile
                (builtins.replaceStrings [ "\n" ] [ "" ])
              ];

          mkSimpleModuleConfig =
            { simpleModules, pkgs }:
            let
              inherit (pkgs.lib) mkMerge mapAttrs;
            in
            mkMerge (
              mapAttrs (
                optionName: config:
                let
                  isProgram = config.isProgram or false;
                  packageName = config.packageName or optionName;
                in
                if isProgram then
                  { programs.${packageName}.enable = true; }
                else
                  { home.packages = [ pkgs.${packageName} ]; }
              ) simpleModules
            );

          recursiveAttrValues =
            attrs:
            lib.pipe attrs [
              builtins.attrValues
              (map (value: if lib.isAttrs value then recursiveAttrValues value else [ value ]))
              builtins.concatLists
            ];

          trivnixLib = {
            inherit
              mkStorePath
              mkFlakePath
              recursiveAttrValues
              mkSimpleModuleConfig
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
    in
    {
      lib = {
        default = makeLib self;
        for = makeLib;
      };
    };
}
