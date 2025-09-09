selfArg:
{
  inputs,
  overlays,
  trivnixLib,
  trivnixConfigs,
}:
{
  configname,
  username,
}:
let
  inherit (inputs.nixpkgs.lib) mapAttrs' nameValuePair;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (trivnixConfigs) configs commonInfos;

  hostConfig = configs.${configname};
  hostPrefs = hostConfig.prefs;
  hostPubKeys = hostConfig.pubKeys;
  userConfig = hostConfig.users.${username};
  userPrefs = userConfig.prefs;
  allOtherHostConfigs = removeAttrs configs [ configname ];
  allOtherUserConfigs = removeAttrs hostConfig.users [ username ];
  allHostInfos = mapAttrs' (name: value: nameValuePair name value.infos) allOtherHostConfigs;
  allHostPrefs = mapAttrs' (name: value: nameValuePair name value.prefs) allOtherHostConfigs;
  allHostPubKeys = mapAttrs' (name: value: nameValuePair name value.pubKeys) allOtherHostConfigs;
  allUserPrefs = mapAttrs' (name: value: nameValuePair name value.prefs) allOtherUserConfigs;
  allUserInfos = mapAttrs' (name: value: nameValuePair name value.prefs) allOtherUserConfigs;
  homeArgs.userInfos = userInfos;

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
      allHostPubKeys
      allHostUserPrefs
      allHostUserInfos
      ;
  };

  hostArgs = {
    inherit
      hostInfos
      hostPrefs
      hostPubKeys
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
homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = generalArgs // hostArgs // homeArgs // { isNixos = false; };

  modules = [
    # Flake entrypoint
    inputs.stylix.homeModules.stylix
    inputs.sops-nix.homeManagerModules.sops
    inputs.spicetify-nix.homeManagerModules.spicetify
    inputs.nvf.homeManagerModules.default

    {
      config = { inherit userPrefs; };

      imports = trivnixLib.resolveDir {
        dirPath = selfArg + "/home";
        preset = "importList";
      };
    }
  ];
}
