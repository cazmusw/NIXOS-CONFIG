{ ... }: {
  imports = [ ./packages.nix ./craft.nix ./firefox.nix ./printing.nix ./screenshots.nix ];
  programs.steam.enable = true;
}
