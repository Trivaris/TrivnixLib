selfArg:
{
  inputs,
  overlays,
  trivnixLib,
  trivnixConfigs,
}:
{
  configname,
  hostModules,
  homeModules,
}:
let
  inherit (inputs.nixpkgs.lib)
    mapAttrs'
    nameValuePair
    nixosSystem
    optionalAttrs
    ;
  inherit (trivnixConfigs) configs commonInfos;

  hostConfig = configs.${configname};
  hostPrefs = hostConfig.prefs;
  allOtherHostConfigs = removeAttrs configs [ configname ];
  allHostInfos = mapAttrs' (name: value: nameValuePair name value.infos) allOtherHostConfigs;
  allHostPrefs = mapAttrs' (name: value: nameValuePair name value.prefs) allOtherHostConfigs;
  allUserPrefs = mapAttrs' (name: value: nameValuePair name value.prefs) hostConfig.users;
  allUserInfos = mapAttrs' (name: value: nameValuePair name value.infos) hostConfig.users;

  hostInfos = hostConfig.infos // {
    inherit configname;
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
    inherit hostInfos allUserPrefs allUserInfos;
  };

  pkgs = import inputs.nixpkgs {
    system = hostConfig.infos.architecture;
    overlays = builtins.attrValues overlays;
    config = hostConfig.pkgsConfig;
  };
in
assert builtins.hasAttr configname configs;
nixosSystem {
  inherit pkgs;
  specialArgs =
    generalArgs
    // hostArgs
    // (optionalAttrs (inputs ? trivnixLib) {
      trivnixLib = inputs.trivnixLib.lib.for { inherit selfArg pkgs; };
    });

  modules =
    hostModules
    ++ (trivnixLib.resolveDir {
      dirPath = selfArg + "/host";
      preset = "importList";
    })
    ++ [
      hostConfig.partitions
      hostConfig.hardware

      {
        config = {
          inherit hostPrefs;
          disko.enableConfig = true;

          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
            extraSpecialArgs = generalArgs // hostArgs // { isNixos = true; };

            backupFileExtension = builtins.readFile (
              pkgs.runCommandNoCC "timestamp" { } "echo -n $(date '+%d-%m-%Y-%H-%M-%S')-backup > $out"
            );

            sharedModules =
              homeModules
              ++ (trivnixLib.resolveDir {
                dirPath = selfArg + "/home";
                preset = "importList";
              });

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
    ];

}
