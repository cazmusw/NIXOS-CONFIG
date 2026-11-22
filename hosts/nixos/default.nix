{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./users.nix
    ../../modules/system
    ../../modules/hardware
    ../../modules/desktop
    ../../modules/applications
  ];
  networking.hostName = "nixos";
  system.stateVersion = "26.05";
}
