{ config, pkgs, lib, ... }: {
  fileSystems."/mnt/main" = {
    device = "/dev/disk/by-uuid/7ab7ec77-b4cb-449b-99af-ca892420f65e";
    fsType = "ext4";
    options = [ "nofail" ];
  };
}
