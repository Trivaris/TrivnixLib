{
  nixpkgs,
  self,
  ...
}@inputs:
{
  getModules =
    path:
    builtins.attrNames (
      removeAttrs (nixpkgs.lib.packagesFromDirectoryRecursive {
        directory = path;
        callPackage = (x: _: x);
      }) [ "default" ]
    );

  getColor =
    pkgs: scheme: name:
    nixpkgs.lib.pipe
      (pkgs.runCommand "color-${name}" {
        inherit scheme;
        nativeBuildInputs = [ pkgs.yq ];
      } "yq -r '.palette.${name}' \"${scheme}\" > $out")
      [
        builtins.readFile
        (builtins.replaceStrings [ "\n" ] [ "" ])
      ];

  recursiveAttrValues =
    attrs:
    nixpkgs.lib.pipe attrs [
      builtins.attrValues
      (map (value: if nixpkgs.lib.isAttrs value then self.lib.recursiveAttrValues value else [ value ]))
      builtins.concatLists
    ];

  mkHomeManager = import ./mkHomeManager.nix inputs;
  mkNixOS = import ./mkNixOS.nix inputs;

  mkReverseProxyOption = import ./mkReverseProxyOption.nix {
    inherit (nixpkgs.lib) types mkOption mkEnableOption;
  };
}
