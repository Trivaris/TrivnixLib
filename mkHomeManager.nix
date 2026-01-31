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

  stylixPrefs = hostConfig.stylix;

  collectAttrs = attrName: attrs: nixpkgs.lib.mapAttrs (_: value: value.${attrName}) attrs;
  allHostInfos = collectAttrs "infos" configs;
  allHostPrefs = collectAttrs "prefs" configs;
  allUserInfos = collectAttrs "infos" hostConfig.users;
  allUserPrefs = collectAttrs "prefs" hostConfig.users;
in
home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    system = hostConfig.infos.architecture;
    overlays = builtins.attrValues overlays;
    config = hostConfig.pkgsConfig;
  };

  extraSpecialArgs = {
    trivnixLib = self.lib;
    inherit
      hostPrefs
      allHostInfos
      allHostPrefs
      allUserInfos
      allUserPrefs
      ;
  };

  modules = modules.home ++ [
    self.nixosModules.default
    # self.nixosModules.stylix
    # stylix.homeManagerModules.default
    (importTree (selfArg + "/home"))
    { inherit userPrefs; }
    { inherit hostInfos; }
    { inherit userInfos; }
    # { inherit stylixPrefs; }
  ];
}
