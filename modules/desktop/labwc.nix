{ pkgs, ... }: {
  # User files in ~/.config/labwc override these system defaults.
  environment.etc."xdg/labwc/environment".text = ''
    XKB_DEFAULT_LAYOUT=us,ru
    XKB_DEFAULT_OPTIONS=grp:alt_shift_toggle
  '';

  environment.etc."xdg/labwc/autostart".text = ''
    ${pkgs.uwsm}/bin/uwsm finalize
    ${pkgs.mako}/bin/mako &
    ${pkgs.swaybg}/bin/swaybg -c '#1e1e2e' &

  '';

  environment.etc."xdg/labwc/rc.xml".source = ../../settings/labwc/rc.xml;
}
