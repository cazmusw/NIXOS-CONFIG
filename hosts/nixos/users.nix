{ config, pkgs, lib, ... }: {
  users.users.catalyst = {
    isNormalUser = true;
    description = "catalyst";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
