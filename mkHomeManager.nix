selfArg:
{
  inputs,
  overlays,
  trivnixConfigs,
  importTree,
}:
{
  configname,
  username,
  homeModules,
}:
let
  inherit (inputs.nixpkgs.lib) mapAttrs' nameValuePair;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (trivnixConfigs) configs commonInfos;

  trivnixLib = inputs.trivnixLib.lib.for { inherit selfArg pkgs; };

  hostConfig = configs.${configname};
  hostPrefs = hostConfig.prefs // {
    stylix = null;
  };
  userConfig = hostConfig.users.${username};
  userPrefs = userConfig.prefs // {
    stylix = hostConfig.prefs.stylix;
  };
  allOtherHostConfigs = removeAttrs configs [ configname ];
  allOtherUserConfigs = removeAttrs hostConfig.users [ username ];
  allHostInfos = mapAttrs' (name: value: nameValuePair name value.infos) allOtherHostConfigs;
  allHostPrefs = mapAttrs' (name: value: nameValuePair name value.prefs) allOtherHostConfigs;
  allUserPrefs = mapAttrs' (name: value: nameValuePair name value.prefs) allOtherUserConfigs;
  allUserInfos = mapAttrs' (name: value: nameValuePair name value.infos) allOtherUserConfigs;

  # Extra args specific to home configs
  homeArgs = {
    userInfos = userInfos;
  };

  hostInfos = hostConfig.infos // {
    inherit configname;
  };

  userInfos = userConfig.infos // {
    name = username;
  };

  allHostUserPrefs = mapAttrs' (
    configname: config:
    nameValuePair configname (
      mapAttrs' (usrname: userconfig: nameValuePair usrname userconfig.prefs) config.users
    )
  ) allOtherHostConfigs;

  allHostUserInfos = mapAttrs' (
    configname: config:
    nameValuePair configname (
      mapAttrs' (usrname: userconfig: nameValuePair usrname userconfig.infos) config.users
    )
  ) allOtherHostConfigs;

  generalArgs = {
    inherit
      inputs
      trivnixLib
      commonInfos
      allHostInfos
      allHostPrefs
      allHostUserPrefs
      allHostUserInfos
      ;
  };

  hostArgs = {
    inherit
      hostInfos
      hostPrefs
      allUserPrefs
      allUserInfos
      ;
  };

  pkgs = import inputs.nixpkgs {
    system = hostConfig.infos.architecture;
    overlays = builtins.attrValues overlays;
    config = hostConfig.pkgsConfig;
  };
in
assert builtins.hasAttr configname configs;
assert builtins.hasAttr username hostConfig.users;
homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = generalArgs // hostArgs // homeArgs // { isNixos = false; };

  modules =
    homeModules ++ [ { config = { inherit userPrefs; }; } (importTree (selfArg + "/home")) ];
}
