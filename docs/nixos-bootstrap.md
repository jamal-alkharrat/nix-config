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

# Root partition (ext4, uses most of the disk, leave ~8GB for swap)
parted /dev/sda -- mkpart root ext4 512MB -8GB

# Swap partition
parted /dev/sda -- mkpart swap linux-swap -8GB 100%

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

Create `/mnt/etc/nixos/configuration.nix`:

```bash
cat > /mnt/etc/nixos/configuration.nix << 'EOF'
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "k3s-vm";
  networking.useDHCP = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPuIMVq34a92QCeVyBpwUfwEkVm2cKH7CldGfN8M8db5 jamalalkharrat@mac.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMiLm8N8B7vY+koFGJR0V1Ca0T13pCM7ysxYK2NMtYtQ jamal@ubuntu"
  ];

  users.users.jamal = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPuIMVq34a92QCeVyBpwUfwEkVm2cKH7CldGfN8M8db5 jamalalkharrat@mac.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMiLm8N8B7vY+koFGJR0V1Ca0T13pCM7ysxYK2NMtYtQ jamal@ubuntu"
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";
}
EOF
```

Replace `YOUR_PUBLIC_KEY_HERE` with your actual SSH public key.

## Step 6: Install

```bash
nixos-install
# Set root password when prompted (temporary fallback)
reboot
```

## Step 7: Verify SSH works, then I take over

```bash
# From your Mac or any machine
ssh root@192.168.0.153
```

Once you're in, tell me and I will:

1. Copy the real `hardware-configuration.nix` into the repo
2. Push the flake config
3. Run `nixos-rebuild switch --flake .#k3s-vm --target-host root@192.168.0.153`
4. Add K3s and everything else via the config

From then on: edit config → push → rebuild. Done.

## Why these steps?

They're the **standard NixOS manual install** from the official docs. The minimal ISO has no installer wizard — you partition, format, generate config, install. No shortcuts here, but it's one-time only. The flake takes over after this.
