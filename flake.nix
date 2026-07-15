{
  description = "System configuration using Nix flakes";

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
    let
      # Systems we target
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      # ── Darwin (macOS) ──────────────────────────────────────────
      # Build: darwin-rebuild build --flake .#mac
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin/darwin-config.nix
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
          }
          sops-nix.darwinModules.sops
        ];
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      };

      # ── NixOS ───────────────────────────────────────────────────
      # Build: nixos-rebuild build --flake .#k3s-vm
      # Deploy: nixos-rebuild switch --flake .#k3s-vm --target-host root@192.168.0.153
      nixosConfigurations = {
        "k3s-vm" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/nixos/k3s-vm
          ];
        };
      };

      # ── Dev shell ──────────────────────────────────────────────
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            nixos-generators
            # For testing configs locally
          ];
        };
      });
    };
}
