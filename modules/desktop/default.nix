{ ... }: {
  imports = [ ./session.nix ./authentication.nix ./portals.nix ./theme.nix ./labwc.nix ./notifications.nix ];
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
