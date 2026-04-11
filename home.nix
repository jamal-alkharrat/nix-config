{ config, pkgs, ... }:

{
  home.username = "jamalalkharrat";
  home.homeDirectory = "/Users/jamalalkharrat";

  # Required: do not change unless you know why
  home.stateVersion = "25.05";

  # Packages installed in your user profile
  home.packages = with pkgs; [
    ripgrep
    curl
    wget
    vim
    htop
  ];

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
  enable = true;
  #settings = {
   #   userName = "Jamal Alkharrat";
    #  userEmail = "jamal.alkharrat@gmail.com";
   # };
  };

programs.lazygit = {
    enable = true;
  };

programs.fd = {
  enable = true;
  ignores = [
    "Library/"
    "Pictures/"
    "Downloads/"
    ".git/"
    "node_modules/"
    "venv/"
    "__pycache__/"
    ".cache/"
    "build/"
    "dist/"
    ".DS_Store"
    "*.log"
    "*.pyc"
  ];
};

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;   # or enableBashIntegration = true;
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bun = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
  };

  # Direnv for per-project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Let Home Manager manage itself
  targets.darwin.defaults = {};

  programs.nh = {
    enable = true;
    flake = "/Users/jamalalkharrat/nix-config";
  };

  programs.pyenv = {
    enable = true;
    enableZshIntegration = true;
    rootDirectory = "${config.xdg.dataHome}/.pyenv";
  };

  #programs.opencode = {
   # enable = true;
    #enableMcpIntegration = true;
  #};

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
  };
}
