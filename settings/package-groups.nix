# Applications installed into the system profile, grouped by purpose.
# Every name has a corresponding entry in versions/packages.nix.
{
  terminal = [ "git" "nano" "curl" "pciutils" "htop" "jq" "zip" "unzip" ];
  desktop = [ "alacritty" "fuzzel" "mako" "swaylock" "swayidle" "swaybg"
    "xwayland" "wl-clipboard" "brightnessctl" "pavucontrol" "libnotify" "xdg-utils" ];
  internet = [ "firefox" "ayugram-desktop" "discord" ];
  development = [ "vscode" ];
  games = [ "prismlauncher" ];
  graphics = [ "grim" "flameshot" ];
  compatibility = [ "appimage-run" ];
  assistants = [ "chatgpt" ];
}
