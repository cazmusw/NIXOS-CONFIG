{ pkgs, ... }: {
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      splix
      samsung-unified-linux-driver
    ];
  };
}
