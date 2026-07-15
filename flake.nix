{
  description = "System configuration using Nix flakes";

  inputs = {
    # Darwin
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # NixOS
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";

    # Shared
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nixpkgs-darwin,
      home-manager,
      sops-nix,
      ...
    }:
    let
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
          home-manager.darwinModules.home-manager
          {
            home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
          }
          sops-nix.darwinModules.sops
        ];
        pkgs = nixpkgs-darwin.legacyPackages.aarch64-darwin;
      };

      # ── NixOS ───────────────────────────────────────────────────
      # Build:   nixos-rebuild build --flake .#k3s-vm
      # Deploy:  nixos-rebuild switch --flake .#k3s-vm \
      #            --target-host root@192.168.0.153
      nixosConfigurations = {
        "k3s-vm" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/nixos/k3s-vm
          ];
        };
      };

      # ── VM Images ──────────────────────────────────────────────
      # Build a disk image ready to import into Proxmox.
      #
      #   nix build .#packages.x86_64-linux.k3s-vm-proxmox
      packages.x86_64-linux.k3s-vm-proxmox =
        let
          image = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              "${nixpkgs}/nixos/modules/image/images.nix"
              ./hosts/nixos/k3s-vm
              # Override image defaults that conflict with our config
              ({ lib, ... }: { networking.useDHCP = lib.mkForce true; })
            ];
          };
        in
          image.config.system.build.images.proxmox;
    };
}
