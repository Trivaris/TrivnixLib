{
  importTree,
  home-manager,
  nixpkgs,
  stylix,
  self,
  ...
}:
{
  overlays,
  configs,
  modules,
  selfArg,
}:
{
  hostConfig,
  userConfig,
}:
let
  hostPrefs = hostConfig.prefs;
  hostInfos = hostConfig.infos;

  userPrefs = userConfig.prefs;
  userInfos = userConfig.info;

  collectAttrs = attrName: attrs: nixpkgs.lib.mapAttrs (_: value: value.${attrName}) attrs;
  allHostInfos = collectAttrs "infos" configs;
  allHostPrefs = collectAttrs "prefs" configs;
  allUserInfos = collectAttrs "infos" hostConfig.users;
  allUserPrefs = collectAttrs "prefs" hostConfig.users;
in
home-manager.lib.homeManagerConfiguration {
  extraSpecialArgs = extraArgs // {
    isHomeManager = true;
    isNixos = false;
    trivnixLib = self.lib;
    inherit
      hostPrefs
      hostInfos
      userInfos
      allHostInfos
      allHostPrefs
      allUserInfos
      allUserPrefs
      ;
  };

  modules = modules.home ++ [
    self.homeManagerModules.default
    stylix.homeModules.stylix
    (importTree (selfArg + "/home"))
    { inherit userPrefs; }
    { userPrefs.stylix = hostConfig.stylix; }
    {
      nixpkgs = {
        system = hostConfig.infos.architecture;
        overlays = builtins.attrValues overlays;
        config = hostConfig.pkgsConfig;
      };
    }
  ];
}
