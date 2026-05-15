{
  description = "Trivnix Helpers and Utilities";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      jdk = pkgs.jdk21;
    in
    {
      overlays.default = final: prev: {
        lib = prev.lib.extend (
          lself: lsuper: {
            getModules =
              path:
              builtins.attrNames (
                removeAttrs (prev.packagesFromDirectoryRecursive {
                  directory = path;
                  callPackage = (x: _: x);
                }) [ "default" ]
              );

            recursiveAttrValues =
              attrs:
              prev.pipe attrs [
                builtins.attrValues
                (map (value: if prev.isAttrs value then final.lib.recursiveAttrValues value else [ value ]))
                builtins.concatLists
              ];

            mkReverseProxyOption = import ./mkReverseProxyOption.nix prev.lib;
          }
        );
      };

      nixosModules = {
        hostInfos = import ./modules/hostInfos.nix;
        pubKeys = import ./modules/pubKeys.nix;
        secrets = import ./modules/secrets.nix;
        theming = import ./modules/theming.nix;
        cfddns = import ./modules/cfddns.nix;
        default = _: {
          imports = [
            self.nixosModules.hostInfos
            self.nixosModules.pubKeys
            self.nixosModules.secrets
            self.nixosModules.theming
            self.nixosModules.cfddns
          ];
        };
      };

      homeModules = {
        userInfos = import ./modules/userInfos.nix;
        secrets = import ./modules/secrets.nix;
        pubKeys = import ./modules/pubKeys.nix;
        emailAccounts = import ./modules/emailAccounts.nix;
        calendarAccounts = import ./modules/calendarAccounts.nix;
        default = _: {
          imports = [
            self.homeModules.userInfos
            self.homeModules.secrets
            self.nixosModules.pubKeys
            self.homeModules.emailAccounts
            self.homeModules.calendarAccounts
          ];
        };
      };

      devShells."${system}" = {
        java = pkgs.mkShell {
          buildInputs = [
            pkgs.python314
            pkgs.gradle_9
            jdk
          ];

          shellHook = ''
            mkdir -p ./.vscode/
            rm -rf ./.vscode/settings.json
            ln -s ${self.packages.${system}.vscode-settings-java} ./.vscode/settings.json
          '';
        };

        kotlin = pkgs.mkShell {
          buildInputs = [
            pkgs.python314
            pkgs.gradle_9
            pkgs.kotlin
            pkgs.kotlin-language-server
            jdk

            pkgs.libxxf86vm
            pkgs.libxtst
            pkgs.glib
            pkgs.gtk3
            pkgs.libGL
            pkgs.tailwindcss
          ];

          shellHook = ''
            mkdir -p ./.vscode/
            rm -rf ./.vscode/settings.json
            ln -s ${self.packages.${system}.vscode-settings-java} ./.vscode/settings.json

            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.xorg.libXtst pkgs.libxxf86vm pkgs.glib pkgs.gtk3 pkgs.libGL]}:$LD_LIBRARY_PATH
          '';
        };
      };

      packages.${system} = {
        vscode-settings-java =
          let
            rawSettings = pkgs.writeText "settings.json" (
              builtins.toJSON {
                "java.compile.nullAnalysis.mode" = "automatic";
                "java.configuration.updateBuildConfiguration" = "interactive";
                "java.jdt.ls.java.home" = jdk.home;
                "java.configuration.runtimes" = [
                  {
                    name = "JavaSE-${builtins.head (builtins.splitVersion jdk.version)}";
                    path = "${jdk.home}";
                    default = true;
                  }
                ];
              }
            );
          in
          pkgs.runCommand "settings.json" {
            nativeBuildInputs = [ pkgs.jq ];
          } "jq . ${rawSettings} > $out";
      };

        vscode-settings-kotlin =
          let
            rawSettings = pkgs.writeText "settings.json" (
              builtins.toJSON {
                "java.compile.nullAnalysis.mode" = "automatic";
                "java.configuration.updateBuildConfiguration" = "interactive";
                "java.jdt.ls.java.home" = jdk.home;
                "kotlin.java.home" = jdk.home;
                "java.configuration.runtimes" = [
                  {
                    name = "JavaSE-${builtins.head (builtins.splitVersion jdk.version)}";
                    path = "${jdk.home}";
                    default = true;
                  }
                ];
              }
            );
          in
          pkgs.runCommand "settings.json" {
            nativeBuildInputs = [ pkgs.jq ];
          } "jq . ${rawSettings} > $out";
      };
  };
}
