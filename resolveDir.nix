{ inputs }: let
  inherit (inputs.nixpkgs) lib;
in {
  dirPath,
  exclude ? [ ],
  preset ? null,
  flags ? [ ],
  depth ? null,
}: let
  mkStorePath = path: "${dirPath}/${path}";
  nixSuffix = ".nix";

  traverseDir = rel: remainingDepth: let
    entries =
      if (remainingDepth == null || remainingDepth > 0) then
        builtins.readDir "${dirPath}/${rel}"
        |> (entries: removeAttrs entries exclude)
      else { };
    nextDepth = if remainingDepth == null then null else remainingDepth - 1;
  in lib.mapAttrs' (name: type:
    lib.nameValuePair name (
      if type == "directory"
      then traverseDir "${rel}/${name}" nextDepth
      else "${dirPath}/${rel}/${name}"
    )
  ) entries;

  collapseAttrs = attrs:
    attrs
    |> (lib.mapAttrsRecursiveCond
          (value: builtins.isAttrs value)
          (path: value: { inherit path value; }))
    |> (lib.collect (x:
          builtins.isAttrs x
          && builtins.hasAttr "path" x
          && builtins.hasAttr "value" x))
    |> (builtins.map ({ path, value }: {
          name  = builtins.concatStringsSep "/" path;
          inherit value;
        }))
    |> builtins.listToAttrs;

  mapValuesToPaths = attrs:
    lib.mapAttrsRecursiveCond (value: builtins.isAttrs value) (path: value:
      if builtins.isAttrs value
      then value
      else builtins.concatStringsSep "/" path
    ) attrs;

  operations = builtins.listToAttrs rawOperations;
  rawOperations = [
    (lib.nameValuePair
      "foldDefault"
      (entries:
        lib.mapAttrs' (name: value:
          lib.nameValuePair
            name
            ( if builtins.isAttrs value then let
              defName = lib.findFirst
                (name: builtins.isString value.${name} && lib.hasSuffix "/default.nix" value.${name})
                null
                (builtins.attrNames value);
              in if defName != null then value.${defName} else operations.foldDefault value
            else value )
        ) entries
      )
    )

    (lib.nameValuePair
      "stripNixSuffix"
      (entries:
        lib.mapAttrs' (name: value:
          lib.nameValuePair
            (if lib.isAttrs value then name else lib.removeSuffix nixSuffix name)
            (if lib.isAttrs value then operations.stripNixSuffix value else value)
        ) entries
      )
    )

    (lib.nameValuePair
      "onlyNixFiles"
      (entries:
        entries |> 
        lib.mapAttrs' (name: value:
          lib.nameValuePair
            name
            (if builtins.isAttrs value then operations.onlyNixFiles value else value)
        ) |> 
        lib.filterAttrs(_: value:
          if builtins.isAttrs value then value != { } else builtins.isString value && lib.hasSuffix nixSuffix value
        )
      )
    )

    (lib.nameValuePair
      "collapse" 
      (entries: collapseAttrs entries)
    )

    (lib.nameValuePair
      "mapImports"
      (entries:
        lib.mapAttrs' (name: value:
          lib.nameValuePair
            name
            (if lib.isAttrs value then operations.mapImports value else if lib.hasSuffix nixSuffix value then import (mkStorePath value) else builtins.readFile (mkStorePath value))
        ) entries
      )
    )
  ];

  orderedOperations =
    rawOperations
    |> map (operation: operation.name)
    |> lib.filter (operation: lib.elem operation flags)
    |> map (operation: operations.${operation});

  presets = {
    importList = [ 
      operations.foldDefault
      operations.onlyNixFiles
      ( lib.filterAttrs (name: _: name != "default.nix") )
      operations.collapse
      builtins.attrValues
      ( map (path: dirPath + "/${path}") )
    ];
    moduleNames = [
      operations.foldDefault
      operations.onlyNixFiles
      ( lib.filterAttrs (name: _: name != "default.nix") )
      operations.stripNixSuffix
      operations.collapse
      builtins.attrNames
    ];
  };

  finalOperations = if preset != null then
    lib.warnIf (flags != [ ])
      "Both `preset` and `flags` are set; using preset and ignoring flags"
      presets.${preset}
  else orderedOperations;

in lib.pipe (traverseDir "" depth |> mapValuesToPaths) finalOperations 
