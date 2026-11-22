{ pkgs, ... }:
let
  groups = import ../../settings/package-groups.nix;
in {
  environment.systemPackages = map (name: pkgs.${name})
    (builtins.concatLists (builtins.attrValues groups));
}
