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
{
  configname,
}:
let
  hostConfig = configs.${configname};
  hostPrefs = hostConfig.prefs;
  hostInfos = hostConfig.infos;

  getAttrs = attrName: attrs: nixpkgs.lib.mapAttrs (name: value: value.${attrName}) attrs;
  allHostInfos = getAttrs "infos" configs;
  allHostPrefs = getAttrs "prefs" configs;
  allUserPrefs = getAttrs "prefs" configs;
  allUserInfos = getAttrs "infos" configs;

  allHostUserPrefs = nixpkgs.lib.mapAttrs (
    _: config: (nixpkgs.lib.mapAttrs (_: userconfig: userconfig.prefs) config.users)
  ) allOtherHostConfigs;

  allHostUserInfos = nixpkgs.lib.mapAttrs (
    _: config: (nixpkgs.lib.mapAttrs (_: userconfig: userconfig.infos) config.users)
  ) allOtherHostConfigs;
in
nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit
      hostInfos
      allHostInfos
      allHostPrefs
      allHostUserPrefs
      allHostUserInfos
      allUserPrefs
      allUserInfos
      ;
  };

  modules = modules.host ++ [
    home-manager.nixosModules.home-manager
    stylix.nixosModules.stylix
    hostConfig.partitions
    hostConfig.hardware
    (importTree (self + "/host"))
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
        config = {
          inherit hostPrefs;
          disko.enableConfig = true;

          home-manager = {
            sharedModules = modules.home ++ [ (importTree (self + "/home")) ];
            extraSpecialArgs = specialArgs // {
              isNixos = true;
            };

            backupFileExtension = builtins.readFile (
              pkgs.runCommand "timestamp" { } "echo -n $(date '+%d-%m-%Y-%H-%M-%S')-backup > $out"
            );

            users = mapAttrs' (
              name: userPrefs:
              let
                userInfos = hostConfig.users.${name}.infos // {
                  inherit name;
                };
              in
              nameValuePair name {
                config = { inherit userPrefs; };
                imports = [ { _module.args = { inherit userInfos; }; } ];
              }
            ) allUserPrefs;
          };
        };
      }
    )
  ];

}
