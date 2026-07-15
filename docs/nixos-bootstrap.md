# NixOS Bootstrap Guide — VM 153 (k3s-vm)

## Overview

This guide walks through installing NixOS on VM 153 from scratch.
After this, all changes happen declaratively via the flake in this repo.

## Prerequisites

- VM 153 already exists on Proxmox (2c/4GB/20GB)
- NixOS minimal ISO attached as CD-ROM
- You have access to Proxmox console (no SSH yet — first boot only)

## Step 1: Boot the Installer

1. Open Proxmox → VM 153 → **Console**
2. Start VM 153
3. The NixOS installer boots automatically
4. Once at the shell prompt (`nixos`), configure networking:

```bash
# Get a DHCP lease
dhcpcd

# Test internet
ping -c 3 nixos.org
```

## Step 2: Partition Disk

```bash
# Wipe and partition (EFI + root)
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MiB -8GiB
parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 3 esp on

# Format
mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3

# Mount
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/sda2
```

## Step 3: Generate Config & Install

```bash
# Generate hardware config
nixos-generate-config --root /mnt

# View the generated hardware-configuration.nix
cat /mnt/etc/nixos/hardware-configuration.nix
# **COPY THIS OUTPUT** — you'll need it for the repo
```

Create a minimal `/mnt/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "k3s-vm";
  networking.useDHCP = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  users.users.root.openssh.authorizedKeys.keys = [
    # YOUR SSH PUBLIC KEY
    "ssh-ed25519 AAAAC3..."
  ];

  users.users.jamal = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # YOUR SSH PUBLIC KEY
      "ssh-ed25519 AAAAC3..."
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";
}
```

Then install:

```bash
nixos-install
# Set root password when prompted (temporary — will use SSH keys)
reboot
```

## Step 4: Replace Repo Config with Real Hardware Config

After reboot, SSH in:

```bash
ssh root@192.168.0.153
# Copy the real hardware config
cat /etc/nixos/hardware-configuration.nix
```

Copy that output into the repo at `hosts/nixos/k3s-vm/hardware-configuration.nix`
(replace the placeholder).

## Step 5: Apply Flake Config

On any machine with the repo cloned:

```bash
nixos-rebuild switch --flake .#k3s-vm --target-host root@192.168.0.153
```

That's it. From now on:

1. Edit configs in `hosts/nixos/k3s-vm/`
2. Push to GitHub
3. Run the nixos-rebuild command above
4. Changes applied, reproducible, version-controlled

## Adding Future VMs

```bash
mkdir -p hosts/nixos/<vm-name>/
# Create configuration.nix + copy hardware-configuration.nix
# Add entry to flake.nix under nixosConfigurations
nixos-rebuild switch --flake .#<vm-name> --target-host root@192.168.0.X
```
