{ pkgs, ... }:
let
  username = "jamalalkharrat";
in
{
  imports = [
    ./system-defaults.nix
    ./homebrew.nix
  ];

  system.primaryUser = username;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    home-manager
  ];
  

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Enable Touch ID support for sudo.
  security.pam.services.sudo_local.touchIdAuth = true;

  nix.gc = {
    automatic = true;
  };

  nix.package = pkgs.lixPackageSets.stable.lix;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  home-manager.users.${username} =
    { pkgs, ... }:
    {
      imports = [ ../home.nix ];
    };
}
