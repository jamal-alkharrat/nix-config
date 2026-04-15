{ config, pkgs, ... }:
let
  username = "jamalalkharrat";
in
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # Required: do not change unless you know why
  home.stateVersion = "25.05";

  # Packages installed in your user profile
  home.packages = with pkgs; [
    ripgrep
    curl
    wget
    vim
    htop
    nixfmt # Nix formatter
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # Importing example file from the dotfiles directory.
    # ".zshrc".source = ./dotfiles/zshrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".config/karabiner/karabiner.json".source = ../dotfiles/karabiner/karabiner.json;
    # VSCode settings and keybindings files in MacOS. in Linux use the path "~/.config/Code/User/" instead
    "/Users/${username}/Library/Application Support/Code/User/settings.json".source =
      ../dotfiles/vscode/settings.json;
    "/Users/${username}/Library/Application Support/Code/User/keybindings.json".source =
      ../dotfiles/vscode/keybindings.json;
    "/Users/${username}/Library/Application Support/Code/User/mcp.json".source =
      ../dotfiles/vscode/mcp.json;
    "/Users/${username}/Library/Application Support/Code/User/prompts".source =
      ../dotfiles/vscode/prompts;
    "/Users/${username}/Library/Application Support/Code/User/prompts".recursive = true;
    "/Users/${username}/Library/Application Support/Code/User/snippets".source =
      ../dotfiles/vscode/snippets;
    "/Users/${username}/Library/Application Support/Code/User/snippets".recursive = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Jamal Alkharrat";
      user.email = "jamal.alkharrat@gmail.com";
    };
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
    enableZshIntegration = true; # or enableBashIntegration = true;
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      bindkey '^I' autosuggest-accept
      bindkey -M viins '^I' autosuggest-accept
    '';
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

  # Let Home Manager manage itself
  targets.darwin.defaults = { };

  programs.nh = {
    enable = true;
    flake = "/Users/${username}/nix-config";
  };

  programs.pyenv = {
    enable = true;
    enableZshIntegration = true;
    rootDirectory = "${config.xdg.dataHome}/.pyenv";
  };

  programs.ghostty = {
    enable = true;
    package = null;
  };

  programs.mcp = {
    enable = true;
    servers = {
      MCP_DOCKER = {
        type = "local";
        command = "docker";
        args = [
          "mcp"
          "gateway"
          "run"
        ];
        enabled = true;
      };
    };
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
    };
  };

}
