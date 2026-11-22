{ flake }:
let
  system = "x86_64-linux";
  inputs = flake.inputs;
  base = import ../versions;
  stable = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };
  unstable = import inputs.nixpkgs-unstable { inherit system; config.allowUnfree = true; };
  select = packages: (import ../overlays/applications.nix {
    inherit inputs system;
    versions = base // { inherit packages; labwc = { version = null; }; };
  }) {} stable;
  fails = expression: !(builtins.tryEval expression).success;
  cases = {
    stable = (select { nano.source = "stable"; }).nano.drvPath == stable.nano.drvPath;
    unstable = (select { nano.source = "unstable"; }).nano.drvPath == unstable.nano.drvPath;
    attribute = (select { editor = { source = "stable"; attribute = "nano"; }; }).editor.drvPath == stable.nano.drvPath;
    independentPin = let pinned = (import ../overlays/applications.nix {
      inputs = inputs // { editor-pin = inputs.nixpkgs; };
      inherit system;
      versions = base // { packages.nano.source = "editor-pin"; labwc.version = null; };
    }) {} stable;
    in pinned.nano.drvPath == stable.nano.drvPath;
    matchingVersion = (select { nano = { source = "stable"; expectedVersion = stable.nano.version; }; }).nano.drvPath == stable.nano.drvPath;
    wrongVersion = fails (select { nano = { source = "stable"; expectedVersion = "unavailable-version"; }; }).nano.drvPath;
    unknownSource = fails (select { nano.source = "missing-source"; }).nano.drvPath;
    missingPackage = fails (select { nano = { source = "stable"; attribute = "nonexistent-package-for-test"; }; }).nano.drvPath;
    labwcOverrideVersionCheck = let selected = (import ../overlays/applications.nix {
      inherit inputs system;
      versions = base // {
        packages.labwc = { source = "unstable"; expectedVersion = "test-custom-version"; };
        labwc = base.labwc // { version = "test-custom-version"; };
      };
    }) {} stable;
    in selected.labwc.version == "test-custom-version";
    labwcVersion = flake.nixosConfigurations.nixos.pkgs.labwc.version == base.labwc.version;
    groupCoverage = let groups = import ../settings/package-groups.nix;
      in builtins.all (name: builtins.hasAttr name base.packages) (builtins.concatLists (builtins.attrValues groups));
  };
in assert builtins.all (x: x) (builtins.attrValues cases); cases
