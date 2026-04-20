{ config, pkgs, ... }:
let username = (import ../common/username.nix).username; in
{
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
    enableZshIntegration = true;
  };

  programs.lazydocker = {
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
    # Tab for accepting autosuggestions.
    # initContent = ''
    #   bindkey '^I' autosuggest-accept
    #   bindkey -M viins '^I' autosuggest-accept
    # '';
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
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };

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
    enableZshIntegration = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font Mono";
      background-opacity = 0.9;
    };
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
    };
  };
}
