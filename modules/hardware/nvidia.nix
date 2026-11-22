{ config, ... }:
let versions = import ../../versions;
in {
  # Blackwell (RTX 5080) requires NVIDIA's open kernel modules.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = true;
    # Driver modules match the selected stock kernel.
    package = config.boot.kernelPackages.nvidiaPackages.${versions.system.nvidiaDriver};
  };
}
