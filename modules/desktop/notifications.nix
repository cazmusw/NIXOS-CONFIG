{ pkgs, ... }:
let
  session = "wayland-session@labwc.desktop.target";
  unit = "mosaic-memory-warning";
  warning = pkgs.writeShellApplication {
    name = unit;
    runtimeInputs = [ pkgs.gawk pkgs.coreutils pkgs.libnotify ];
    text = builtins.readFile ../../settings/mako/memory-warning.sh;
  };
in {
  environment.etc."xdg/mako/config".source = ../../settings/mako/config;

  systemd.user.services.${unit} = {
    description = "Warn when the system is low on available RAM";
    after = [ session ];
    requisite = [ session ];
    partOf = [ session ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${warning}/bin/${unit}";
    };
  };

  systemd.user.timers.${unit} = {
    description = "Check available RAM in the Labwc session";
    partOf = [ session ];
    wantedBy = [ session ];
    timerConfig = {
      OnActiveSec = "5s";
      OnUnitInactiveSec = "15s";
      AccuracySec = "1s";
    };
  };
}
