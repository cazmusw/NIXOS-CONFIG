{ ... }: {
  virtualisation.docker.enable = true;
  zramSwap = { enable = true; memoryPercent = 50; };
  services.fstrim.enable = true;
}
