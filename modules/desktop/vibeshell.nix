{ pkgs, vibeshell, ... }:
let
  session = "wayland-session@labwc.desktop.target";
  fileManager = "org.mosaic.Files.desktop";
  # A saved Thunar association takes precedence over the system XDG default.
  migrateFileManager = pkgs.writeShellScript "vibeshell-directory-default" ''
    mimeapps="''${XDG_CONFIG_HOME:-$HOME/.config}/mimeapps.list"
    if [ -r "$mimeapps" ] && ${pkgs.gawk}/bin/awk '
      /^\[/ { defaults = ($0 == "[Default Applications]") }
      defaults && /^inode\/directory=(thunar\.desktop|org\.xfce\.Thunar\.desktop)(;|$)/ { found = 1 }
      END { exit !found }
    ' "$mimeapps"; then
      exec ${pkgs.glib.bin}/bin/gio mime inode/directory ${fileManager}
    fi
  '';
  sessionService = {
    after = [ session "graphical-session.target" "wayland-session-waitenv.service" ];
    partOf = [ session "graphical-session.target" ];
    requisite = [ session ];
    wantedBy = [ session ];
    unitConfig = {
      StartLimitIntervalSec = 30;
      StartLimitBurst = 3;
    };
  };
in
{
  environment.systemPackages = [ vibeshell ];

  xdg.mime = {
    enable = true;
    defaultApplications."inode/directory" = fileManager;
  };

  systemd.user.services.mosaic-services = sessionService // {
    description = "Mosaic Shell backend";
    environment.MOSAIC_BLUETOOTH_PAIRING = "1";
    serviceConfig = {
      ExecStart = "${vibeshell}/bin/mosaic-services";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

  systemd.user.services.mosaic-shell = sessionService // {
    description = "Mosaic Shell panel and Dock";
    # GIO resolves desktop entries' Exec and TryExec against the UWSM session PATH.
    enableDefaultPath = false;
    wants = [ "mosaic-services.service" ];
    after = sessionService.after ++ [ "mosaic-services.service" ];
    serviceConfig = {
      ExecStartPre = "-${migrateFileManager}";
      ExecStart = "${vibeshell}/bin/mosaic-shell";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };
}
