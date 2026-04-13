{
  description = "NixOS configurations — server & desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, ... }@inputs:
  let
    system = "x86_64-linux";
    lib    = nixpkgs.lib;
  in {
    # ── NixOS hosts ──────────────────────────────────────────────────────────
    nixosConfigurations = {

      server = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          ./hosts/server/configuration.nix
          ./hosts/server/disko.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs   = true;
            home-manager.useUserPackages = true;
            home-manager.users.ns        = import ./home-manager/ns/home.nix;
          }
        ];
      };

      desktop = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          ./hosts/desktop/configuration.nix
          ./hosts/desktop/disko.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs   = true;
            home-manager.useUserPackages = true;
            home-manager.users.ns        = import ./home-manager/ns/home.nix;
          }
        ];
      };
    };
  };
}
