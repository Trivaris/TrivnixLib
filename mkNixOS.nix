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

  stylixPrefs = hostConfig.stylix;

  collectAttrs = attrName: attrs: nixpkgs.lib.mapAttrs (_: value: value.${attrName}) attrs;
  allHostInfos = collectAttrs "infos" configs;
  allHostPrefs = collectAttrs "prefs" configs;
  allUserInfos = collectAttrs "infos" hostConfig.users;
  allUserPrefs = collectAttrs "prefs" hostConfig.users;

  specialArgs = {
    trivnixLib = self.lib;
    isNixos = true;
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
    stylix.nixosModules.stylix
    self.nixosModules.default
    self.nixosModules.stylix
    hostConfig.partitions
    hostConfig.hardware
    (importTree (selfArg + "/host"))
    { inherit hostPrefs; }
    { inherit hostInfos; }
    { inherit stylixPrefs; }
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
            self.nixosModules.stylixOptions
            (importTree (selfArg + "/home"))
            { inherit hostInfos; }
            { inherit stylixPrefs; }
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
