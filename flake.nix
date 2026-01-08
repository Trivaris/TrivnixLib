{
  description = "Trivnix Helpers and Utilities";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    importTree.url = "github:vic/import-tree";
    stylix.url = "github:danth/stylix";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      lib = import ./lib.nix inputs;

      nixosModules = {
        stylix = import ./modules/stylix/nixos.nix;
        hostInfos = import ./modules/hostInfos.nix;
        calendarAccounts = import ./modules/calendarAccounts.nix;
        emailAccounts = import ./modules/emailAccounts.nix;
        pubKeys = import ./modules/pubKeys.nix;
        secrets = import ./modules/secrets.nix;
        default = _: {
          imports = [
            self.nixosModules.hostInfos
            self.nixosModules.calendarAccounts
            self.nixosModules.emailAccounts
            self.nixosModules.pubKeys
            self.nixosModules.secrets
          ];
        };
      };

      homeManagerModules = {
        stylix = import ./modules/stylix/home.nix;
      };
    };
}
