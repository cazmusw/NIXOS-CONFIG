{ pkgs, lib, ... }:
let versions = import ../../versions;
in {
  boot.kernelPackages = lib.mkForce pkgs.${versions.system.kernelPackage};
}
