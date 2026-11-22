{ pkgs, ... }: {
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
  {
    lockAll = true;

    settings."org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };
    settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
    };
  }
  ];
  fonts.packages = with pkgs; [
    dejavu_fonts
    noto-fonts
    noto-fonts-color-emoji
    corefonts


  ];
}
