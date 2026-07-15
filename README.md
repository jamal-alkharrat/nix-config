# Nix Config — Mac + NixOS VMs

Personal Nix flake repo managing all machines:

- **mac** — MacBook (nix-darwin + home-manager)
- **k3s-vm** — NixOS VM on Proxmox (K3s single node)
- More VMs planned (vm151, vm152 migration)

## Quick commands

```bash
# Darwin (on Mac)
darwin-rebuild switch --flake .#mac

# NixOS (deploy remotely)
nixos-rebuild switch --flake .#k3s-vm --target-host root@192.168.0.153
```

## Structure

```
nix-config/
├── flake.nix                # Entry point — all machines
├── hosts/
│   ├── nixos/
│   │   └── k3s-vm/          # NixOS VM configs
│   └── darwin/              # Mac config
├── common/                  # Shared expressions
├── home/                    # Home-manager modules
├── secrets/                 # sops-nix encrypted secrets
├── dotfiles/                # VSCode, Karabiner
└── docs/                    # Guides
```

## Bootstrap a new NixOS VM

See [docs/nixos-bootstrap.md](docs/nixos-bootstrap.md).

## Useful links

- [Nix flakes](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake)
- [nix-darwin](https://github.com/nix-darwin/nix-darwin)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Nixpkgs search](https://search.nixos.org/packages)
