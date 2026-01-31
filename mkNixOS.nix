{
  nixpkgs,
  home-manager,
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
    inherit
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
    self.nixosModules.default
    hostConfig.partitions
    hostConfig.hardware
    (importTree (selfArg + "/host"))
    { inherit hostPrefs; }
    { inherit hostInfos; }
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
          extraSpecialArgs = specialArgs;
          sharedModules = modules.home ++ [
            self.nixosModules.default
            (importTree (selfArg + "/home"))
            { inherit hostInfos; }
          ];

          backupFileExtension = builtins.readFile (
            pkgs.runCommand "timestamp" { } "echo -n $(date '+%d-%m-%Y-%H-%M-%S')-backup > $out"
          );

          users = nixpkgs.lib.mapAttrs (name: userPrefs: {
            config = { inherit userPrefs; };
            imports = [
              { userInfos = hostConfig.users.${name}.infos; }
            ];
          }) allUserPrefs;
        };
      }
    )
  ];

}
