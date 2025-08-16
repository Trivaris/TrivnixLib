{ inputs, mkFlakePath, mkStorePath }: let
  inherit (inputs.nixpkgs) lib;
in {
  dirPath,
  mode,
  dropNixExtension ? false,
  exclude ? [ ],
  depth ? 1,
  includeNonNix? false
}: let
  inherit (lib) mapAttrs' nameValuePair;

  nixSuffix = ".nix";
  flakePath = mkFlakePath dirPath;

  filterEntries = entries: lib.filterAttrs (name: type: includeNonNix || lib.hasSuffix nixSuffix name || type == "directory") entries;
  
  dropNixExtensions = recursive: entries:
    mapAttrs' (name: value:
      nameValuePair
        (if dropNixExtension && (lib.hasSuffix nixSuffix name) && !(value == "directory") then lib.removeSuffix nixSuffix name else name)
        (if recursive && (builtins.isAttrs value) then (dropNixExtensions true value) else value)
    ) entries;

  traverseDir = rel: remainingDepth: let
    entries =
      if remainingDepth > 0 then
        builtins.readDir (mkFlakePath "${dirPath}/${rel}")
        |> (entries: removeAttrs entries exclude)
      else { };
  in mapAttrs' (name: type:
    nameValuePair name (
      if type == "directory" then
        if mode == "importList" && builtins.pathExists (mkFlakePath "${dirPath}/${rel}/${name}/default.nix")
        then name else traverseDir "${rel}/${name}" (remainingDepth - 1)
      else type
    )
  ) entries;

  collectAttrs = {
    pathMode ? false,
    prefix ? "",
    separator ? "/",
    includeSets ? false,
    asSet ? false
  }: inputSet: let
    formatName = path:
      if pathMode then lib.concatStringsSep separator path else lib.last path;

    mkResult = name: value:
      if asSet then lib.nameValuePair name value else name;

    traverse = path: value:
      if builtins.isAttrs value then
        (lib.optional includeSets (mkResult (prefix + formatName path) value))
        ++ (
        value
        |>  lib.mapAttrsToList (childName: childValue: traverse (path ++ [ childName ]) childValue)
        |>  lib.concatLists )
      else [ (mkResult (prefix + formatName path) value) ];

    results = 
    inputSet
    |>  lib.mapAttrsToList (name: value: traverse [ name ] value)
    |>  lib.concatLists;
  in
    if asSet
    then lib.listToAttrs results
    else results;

  operations = {
    plain = entries:
      entries
      |> filterEntries
      |> (dropNixExtensions true);

    names = entries:
      entries
      |> filterEntries
      |> (dropNixExtensions true)
      |> (collectAttrs { });

    paths = entries:
      entries
      |> filterEntries
      |> (dropNixExtensions true)
      |> (collectAttrs { pathMode = true; });

    fullPaths = entries:
      entries
      |> filterEntries
      |> (dropNixExtensions true)
      |> (collectAttrs { pathMode = true; prefix = "${flakePath}/"; });

    importList = entries:
      entries
      |> filterEntries
      |> (dropNixExtensions true)
      |> (collectAttrs { pathMode = true; prefix = "${toString flakePath}/"; })
      |> map mkStorePath;

    imports = entries:
      entries
      |> collectAttrs { pathMode = true; prefix = "${toString flakePath}/"; }
      |> map
        (path:
          nameValuePair
            (baseNameOf path) 
            ( if lib.hasSuffix nixSuffix path
              then (import (mkStorePath path))
              else (builtins.readFile (mkStorePath path)))
        )
      |> builtins.listToAttrs
      |> filterEntries
      |> (dropNixExtensions true);
  };
in operations.${mode} (traverseDir "" depth)
