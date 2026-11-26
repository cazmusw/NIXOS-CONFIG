{ pkgs, ... }: {
  # User files in ~/.config/labwc override these system defaults.
  environment.etc."xdg/labwc/environment".text = ''
    XKB_DEFAULT_LAYOUT=us,ru
    XKB_DEFAULT_OPTIONS=grp:alt_shift_toggle
  '';

  environment.etc."xdg/labwc/autostart".text = ''
    ${pkgs.uwsm}/bin/uwsm finalize
    ${pkgs.uwsm}/bin/uwsm app -s b -- ${pkgs.mako}/bin/mako &
    ${pkgs.uwsm}/bin/uwsm app -s b -- ${pkgs.swaybg}/bin/swaybg -c '#1e1e2e' &
  '';

  environment.etc."xdg/labwc/rc.xml".source = ../../settings/labwc/rc.xml;

  # UWSM owns the compositor unit. Keep it running if a child is killed by OOM.
  systemd.user.services."wayland-wm@labwc.desktop" = {
    overrideStrategy = "asDropin";
    enableDefaultPath = false;
    serviceConfig.OOMPolicy = "continue";
  };
}
