{
  description = "Trivnix Helpers and Utilities";

  outputs =
    { self }:
    {
      overlays.default = _: prev: {
        lib = prev.lib.extend (lself: lsuper: {
          getModules =
            path:
            builtins.attrNames (
              removeAttrs (prev.packagesFromDirectoryRecursive {
                directory = path;
                callPackage = (x: _: x);
              }) [ "default" ]
            );

          recursiveAttrValues =
            attrs:
            prev.pipe attrs [
              builtins.attrValues
              (map (value: if prev.isAttrs value then self.lib.recursiveAttrValues value else [ value ]))
              builtins.concatLists
            ];
          
          mkReverseProxyOption = import ./mkReverseProxyOption.nix prev;
        });
      };

      nixosModules = {
        hostInfos = import ./modules/hostInfos.nix;
        pubKeys = import ./modules/pubKeys.nix;
        secrets = import ./modules/secrets.nix;
        theming = import ./modules/theming.nix;
        default = _: {
          imports = [
            self.nixosModules.hostInfos
            self.nixosModules.calendarAccounts
            self.nixosModules.emailAccounts
            self.nixosModules.pubKeys
            self.nixosModules.secrets
            self.nixosModules.theming
          ];
        };
      };

      homeModules = {
        userInfos = import ./modules/userInfos.nix;
        secrets = import ./modules/secrets.nix;
        pubKeys = import ./modules/pubKeys.nix;
        emailAccounts = import ./modules/emailAccounts.nix;
        calendarAccounts = import ./modules/calendarAccounts.nix;
        default = _: {
          imports = [
            self.homeModules.userInfos
            self.homeModules.secrets
            self.homeModules.emailAccounts
            self.homeModules.calendarAccounts
          ];
        };
      };
    };
}
