{
  description = "MacOS configuration using nix-darwin and home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      sops-nix,
      ...
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#mac
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin/darwin-config.nix
          inputs.home-manager.darwinModules.home-manager
          {
            # Expose sops options inside Home Manager modules.
            home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
          }
          sops-nix.darwinModules.sops
        ];
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      };
    };
}
