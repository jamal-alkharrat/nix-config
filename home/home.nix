{ config, pkgs, ... }:
let
  username = (import ../common/username.nix).username;
in
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # Required: do not change unless you know why
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Let Home Manager manage itself
  targets.darwin.defaults = { };

  # Packages installed in your user profile
  home.packages = with pkgs; [
    ripgrep
    curl
    wget
    vim
    htop
    nixfmt # Nix formatter
  ];

  imports = [
    ./mcp.nix
    ./home-file.nix
    ./programs.nix
    # ./env.nix # Environment variables for the user, ignored because it contains secrets. Please create this file and add your environment variables there.
    ./env.nix
  ];
}
