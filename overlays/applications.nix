{ inputs, system, versions ? import ../versions }:
let
  lib = inputs.nixpkgs.lib;
  sourceNames = { stable = "nixpkgs"; unstable = "nixpkgs-unstable"; };
  sources = builtins.mapAttrs (_: input: import input {
    inherit system;
    config.allowUnfree = true;
  }) (builtins.removeAttrs inputs [ "self" ]);
in final: prev:
let
  resolve = name: selection:
    let
      source = sourceNames.${selection.source} or selection.source;
      # Keep the host package graph for its own source (Steam/NVIDIA integration).
      packages = if source == "nixpkgs" then prev else
        sources.${source} or (throw "Unknown package source: ${selection.source} (${name})");
      path = lib.splitString "." (selection.attribute or name);
      package = lib.attrByPath path (throw "Package ${name} is absent from ${source}") packages;
    in package;
  checkVersion = name: package:
    let expected = versions.packages.${name}.expectedVersion or null;
    in if expected != null && (package.version or null) != expected
       then throw "Version mismatch for ${name}: expected ${expected}, got ${package.version or "unknown"}"
       else package;
  selected =
  (builtins.mapAttrs resolve versions.packages) // lib.optionalAttrs (versions.labwc.version != null) {
    labwc = (resolve "labwc" versions.packages.labwc).overrideAttrs (_: {
      inherit (versions.labwc) version;
      src = sources.nixpkgs-unstable.fetchFromGitHub {
        owner = "labwc";
        repo = "labwc";
        tag = versions.labwc.version;
        inherit (versions.labwc) hash;
      };
    });
  };
in builtins.mapAttrs checkVersion selected
