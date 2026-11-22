{
  description = "Modular NixOS configuration for catalyst";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Add an independent nixpkgs input pinned to a commit here to pin one app.
  };

  outputs = inputs@{ nixpkgs, ... }:
    let system = "x86_64-linux";
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/nixos
          { nixpkgs.overlays = [ (import ./overlays/applications.nix { inherit inputs system; }) ]; }
        ];
      };
    };
}
