{
  importTree,
  home-manager,
  nixpkgs,
  self,
  ...
}:
{
  overlays,
  configs,
  homeModules,
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

  modules = homeModules ++ [
    self.nixosModules.default
    (importTree (selfArg + "/home"))
    { inherit userPrefs; }
    { inherit hostInfos; }
    { inherit userInfos; }
    { themingPrefs = hostConfig.theming; }
  ];
}
