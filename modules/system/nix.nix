{ config, pkgs, lib, ... }: {
  nixpkgs.config.allowUnfree = true;
  nix = {
    gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 14d"; };
    optimise.automatic = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = lib.mkForce [ "https://cache.nixos.org" ];
      extra-substituters = lib.mkForce [];
      min-free = 20 * 1024 * 1024 * 1024;
      max-free = 40 * 1024 * 1024 * 1024;
    };
  };
}
