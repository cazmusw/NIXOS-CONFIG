{ ... }: {
  virtualisation.docker.enable = true;
  zramSwap = { enable = true; memoryPercent = 50; };
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024;
    priority = 0;
    randomEncryption.enable = true;
  }];
  services.fstrim.enable = true;
}
