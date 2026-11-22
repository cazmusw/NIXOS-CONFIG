{ pkgs, ... }: {
  programs.labwc.enable = true;
  programs.uwsm = {
    enable = true;
    waylandCompositors.labwc = {
      prettyName = "Labwc";
      binPath = "/run/current-system/sw/bin/labwc";
    };
  };
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd '${pkgs.uwsm}/bin/uwsm start -- labwc.desktop'";
      user = "greeter";
    };
  };
}
