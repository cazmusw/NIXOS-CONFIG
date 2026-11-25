# source: stable, unstable, or the name of a separate nixpkgs flake input.
# attribute: optional package attribute path (e.g. "firefox-esr").
# expectedVersion: optional assertion; checks a version, does not change it.
{
  git = { source = "stable"; };
  nano = { source = "stable"; };
  curl = { source = "stable"; };
  pciutils = { source = "stable"; };
  htop = { source = "stable"; };
  jq = { source = "stable"; };
  zip = { source = "stable"; };
  unzip = { source = "stable"; };
  alacritty = { source = "stable"; };
  fuzzel = { source = "stable"; };
  mako = { source = "stable"; };
  swaylock = { source = "stable"; };
  swayidle = { source = "stable"; };
  swaybg = { source = "stable"; };
  xwayland = { source = "stable"; };
  wl-clipboard = { source = "stable"; };
  brightnessctl = { source = "stable"; };
  pavucontrol = { source = "stable"; };
  libnotify = { source = "stable"; };
  xdg-utils = { source = "stable"; };
  firefox = { source = "stable"; };
  ayugram-desktop = { source = "stable"; };
  discord = { source = "stable"; };
  vscode = { source = "stable"; };
  prismlauncher = { source = "stable"; };
  grim = { source = "stable"; };
  flameshot = { source = "stable"; };
  appimage-run = { source = "stable"; };
  tuigreet = { source = "stable"; };
  uwsm = { source = "stable"; };
  polkit_gnome = { source = "stable"; };
  xdg-desktop-portal-gtk = { source = "stable"; };
  xdg-desktop-portal-wlr = { source = "stable"; };
  slurp = { source = "stable"; };
  splix = { source = "stable"; };
  samsung-unified-linux-driver = { source = "stable"; };
  dejavu_fonts = { source = "stable"; };
  noto-fonts = { source = "stable"; };
  noto-fonts-color-emoji = { source = "stable"; };
  corefonts = { source = "stable"; };
  steam = { source = "stable"; };
  chatgpt = { source = "unstable"; };
  xpipe = { source = "unstable"; };
  labwc = { source = "unstable"; };
}
