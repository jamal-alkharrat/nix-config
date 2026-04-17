# MacOS configuration with nix-darwin and Home Manager

My personal MacOS configuration using nix-darwin and Home Manager, managed with Nix flakes.

## Quick command cheat sheet

To build and activate the system configuration (nix-darwin):

```bash
sudo darwin-rebuild build --flake .#mac
sudo darwin-rebuild switch --flake .#mac
```

Both nix-darwin and Home Manager configurations are built together, so you only need to run the above commands to apply all changes. This can be changed so that Home Manager is built separately, but I prefer the simplicity of one command to build and apply everything.

## Useful learning links

Core Nix and flakes:

- Nix flakes command reference:
  - https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake
- Nix language and docs hub:
  - https://nix.dev/

nix-darwin:

- nix-darwin repository and getting started:
  - https://github.com/nix-darwin/nix-darwin
- nix-darwin manual:
  - https://nix-darwin.github.io/nix-darwin/manual/index.html

Home Manager:

- Home Manager repository:
  - https://github.com/nix-community/home-manager
- Home Manager manual:
  - https://nix-community.github.io/home-manager/
- Home Manager options search:
  - https://home-manager-options.extranix.com/

Nixpkgs package search:

- https://search.nixos.org/packages
