{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Hostname
  networking.hostName = "k3s-vm";
  networking.useDHCP = true;

  # SSH — enabled so we can manage it remotely
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # User
  users.users.jamal = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # FIXME: Add your SSH public key(s) here
      # Example: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA..."
    ];
  };

  # Allow passwordless sudo for wheel
  security.sudo.wheelNeedsPassword = false;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
  ];

  system.stateVersion = "26.05";
}
