{ ... }: {
  networking = { networkmanager.enable = true; enableIPv6 = false; };
  boot.kernelParams = [ "ipv6.disable=1" ];
}
