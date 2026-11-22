{ pkgs, lib, ... }:

let
  mkCraft = { name, title, version, sha256, category }:
    let
      package = pkgs.appimageTools.wrapType2 {
        pname = name;
        inherit version;

        src = pkgs.fetchurl {
          url = "https://github.com/storytold/${name}/releases/download/v${version}/${name}-${version}-linux-x86_64.AppImage";
          inherit sha256;
        };
      };

      desktop = pkgs.makeDesktopItem {
        inherit name;
        desktopName = title;
        exec = name;
        terminal = false;
        categories = [ category ];
      };
    in
      [ package desktop ];

  apps = (import ../../versions).craft;

in
{
  environment.systemPackages = lib.concatMap mkCraft apps;
}
