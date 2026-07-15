# NixOS Bootstrap Guide — VM 153 (k3s-vm)

This is the **one-time** manual install. After this, all changes happen declaratively via the flake.

## Before you start

You need your **SSH public key** ready. If you don't have one:

```bash
# On your Mac
cat ~/.ssh/id_ed25519.pub
# If that file doesn't exist: ssh-keygen -t ed25519
```

## Step 1: Boot the ISO

1. Proxmox → VM 153 → **Console**
2. Start VM
3. At the `nixos>` prompt, get networking:

```bash
dhcpcd
ping -c 3 nixos.org  # verify internet
```

## Step 2: Partition Disk (UEFI)

These commands match the [official NixOS manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning-UEFI).

```bash
# Wipe + GPT
parted /dev/sda -- mklabel gpt

# Root partition (ext4, uses most of the disk, leave ~4GB for swap)
parted /dev/sda -- mkpart root ext4 512MB -4GB

# Swap partition (4GB — enough for 10GB RAM VM, no hibernation)
parted /dev/sda -- mkpart swap linux-swap -4GB 100%

# EFI boot partition
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 3 esp on
```

## Step 3: Format & Mount

```bash
mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/sda2
```

## Step 4: Generate Hardware Config

```bash
nixos-generate-config --root /mnt
```

Now **copy this output** — we'll store it in the repo:

```bash
cat /mnt/etc/nixos/hardware-configuration.nix
```

Save it somewhere (it's auto-detected UUIDs/device paths specific to this VM).

## Step 5: Minimal config for first boot

The repo already has a config at `hosts/nixos/k3s-vm/configuration.nix` with your SSH keys.
Copy it over:

```bash
# Download the config from the repo
curl -o /mnt/etc/nixos/configuration.nix \
  https://raw.githubusercontent.com/jamal-alkharrat/nix-config/main/hosts/nixos/k3s-vm/configuration.nix
```

## Step 6: Install

```bash
nixos-install
# Set root password when prompted (temporary fallback)
reboot
```

## Step 7: Done

SSH in: `ssh root@192.168.0.153`

From then on: edit config in repo → push → run `nixos-rebuild switch --flake .#k3s-vm --target-host root@192.168.0.153`

---

> **Note:** This guide is for reference. I'll do the install myself via Proxmox serial console.
