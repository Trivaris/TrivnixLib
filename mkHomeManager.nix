{
  importTree,
  home-manager,
  nixpkgs,
  stylix,
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
  username,
}:
let
  hostConfig = configs.${configname};
  hostPrefs = removeAttrs hostConfig.prefs [ "stylix" ];
  hostInfos = hostConfig.infos;

  userConfig = hostConfig.users.${username};
  userPrefs = userConfig.prefs // {
    inherit (hostConfig.prefs) stylix;
  };
  userInfos = userConfig.infos // {
    name = username;
  };

  getAttrs =
    attrName: attrs:
    nixpkgs.lib.mapAttrs' (name: value: nixpkgs.lib.nameValuePair name value.${attrName}) attrs;
  allHostInfos = getAttrs "infos" allOtherHostConfigs;
  allHostPrefs = getAttrs "prefs" allOtherHostConfigs;
  allUserPrefs = getAttrs "prefs" allOtherUserConfigs;
  allUserInfos = getAttrs "infos" allOtherUserConfigs;

  allHostUserPrefs = nixpkgs.lib.mapAttrs (
    _: config: (nixpkgs.lib.mapAttrs (_: userconfig: userconfig.prefs) config.users)
  ) allOtherHostConfigs;

  allHostUserInfos = nixpkgs.lib.mapAttrs (
    _: config: (nixpkgs.lib.mapAttrs (_: userconfig: userconfig.infos) config.users)
  ) allOtherHostConfigs;
in
homeManagerConfiguration {
  extraSpecialArgs = {
    isNixos = false;
    inherit
      userInfos
      allHostInfos
      allHostPrefs
      allHostUserPrefs
      allHostUserInfos
      hostInfos
      hostPrefs
      allUserPrefs
      allUserInfos
      ;
  };

  modules = modules.home ++ [
    stylix.homeModules.stylix
    { inherit userPrefs; }
    (importTree (self + "/home"))
    {
      nixpkgs = {
        system = hostConfig.infos.architecture;
        overlays = builtins.attrValues overlays;
        config = hostConfig.pkgsConfig;
      };
    }
  ];
}
