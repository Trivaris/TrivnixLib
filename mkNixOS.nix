{
  nixpkgs,
  home-manager,
  stylix,
  importTree,
  ...
}:
{
  overlays,
  configs,
  modules,
  self,
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
in
nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit
      hostInfos
      allHostInfos
      allHostPrefs
      allUserInfos
      allUserPrefs
      ;
  };

  modules = modules.host ++ [
    home-manager.nixosModules.home-manager
    stylix.nixosModules.stylix
    hostConfig.partitions
    hostConfig.hardware
    (importTree (self + "/host"))
    { config = hostPrefs; }
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
          sharedModules = modules.home ++ [ (importTree (self + "/home")) ];
          extraSpecialArgs = { isNixos = true; };

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
