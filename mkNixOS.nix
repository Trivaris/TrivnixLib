{
  nixpkgs,
  home-manager,
  stylix,
  importTree,
  self,
  ...
}:
{
  overlays,
  configs,
  modules,
  selfArg,
}:
hostConfig:
let
  hostPrefs = hostConfig.prefs;
  hostInfos = hostConfig.infos;

  collectAttrs = attrName: attrs: nixpkgs.lib.mapAttrs (_: value: value.${attrName}) attrs;
  allHostInfos = collectAttrs "infos" configs;
  allHostPrefs = collectAttrs "prefs" configs;
  allUserInfos = collectAttrs "infos" hostConfig.users;
  allUserPrefs = collectAttrs "prefs" hostConfig.users;
  
  specialArgs = {
    trivnixLib = self.lib;
    isNixos = true;
    isHomeManager = false;
    inherit
      hostInfos
      allHostInfos
      allHostPrefs
      allUserInfos
      allUserPrefs
      ;
  };
in
nixpkgs.lib.nixosSystem {
inherit specialArgs;

  modules = modules.host ++ [
    home-manager.nixosModules.home-manager
    stylix.nixosModules.stylix
    hostConfig.partitions
    hostConfig.hardware
    (importTree (selfArg + "/host"))
    { inherit hostPrefs; }
    { hostPrefs.stylix = hostConfig.stylix; }
    { disko.enableConfig = true; }
    {
      nixpkgs = {
        system = hostConfig.infos.architecture;
        overlays = builtins.attrValues overlays;
        config = hostConfig.pkgsConfig;
      };
    }
    (
      { pkgs, ... }:
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = modules.home ++ [ (importTree (selfArg + "/home")) ];
          extraSpecialArgs = specialArgs // { isHomeManager = true; };

          backupFileExtension = builtins.readFile (
            pkgs.runCommand "timestamp" { } "echo -n $(date '+%d-%m-%Y-%H-%M-%S')-backup > $out"
          );

          users = nixpkgs.lib.mapAttrs (name: userPrefs: {
            config = { inherit userPrefs; };
            imports = [
              {
                _module.args = {
                  userInfos = hostConfig.users.${name}.infos;
                };
              }
            ];
          }) allUserPrefs;
        };
      }
    )
  ];

}
