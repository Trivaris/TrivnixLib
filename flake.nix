{
  description = "Trivnix Helpers and Utilities";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    importTree.url = "github:vic/import-tree";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      overlays.default = _: prev: {
        lib = prev.lib.extend (lself: lsuper: {
          getModules =
            path:
            builtins.attrNames (
              removeAttrs (nixpkgs.lib.packagesFromDirectoryRecursive {
                directory = path;
                callPackage = (x: _: x);
              }) [ "default" ]
            );

          recursiveAttrValues =
            attrs:
            nixpkgs.lib.pipe attrs [
              builtins.attrValues
              (map (value: if nixpkgs.lib.isAttrs value then self.lib.recursiveAttrValues value else [ value ]))
              builtins.concatLists
            ];
          
          mkReverseProxyOption = import ./mkReverseProxyOption.nix {
            inherit (nixpkgs.lib) types mkOption mkEnableOption;
          };


          mkHomeManager = import ./mkHomeManager.nix inputs;
          mkNixOS = import ./mkNixOS.nix inputs;
        })
      };

      nixosModules = {
        hostInfos = import ./modules/hostInfos.nix;
        userInfos = import ./modules/userInfos.nix;
        calendarAccounts = import ./modules/calendarAccounts.nix;
        emailAccounts = import ./modules/emailAccounts.nix;
        pubKeys = import ./modules/pubKeys.nix;
        secrets = import ./modules/secrets.nix;
        theming = import ./modules/theming.nix;
        default = _: {
          imports = [
            self.nixosModules.hostInfos
            self.nixosModules.userInfos
            self.nixosModules.calendarAccounts
            self.nixosModules.emailAccounts
            self.nixosModules.pubKeys
            self.nixosModules.secrets
            self.nixosModules.theming
          ];
        };
      };
    };
}
