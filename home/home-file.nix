let username = (import ../common/username.nix).username; in
{
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
    # "/Users/${username}/Library/Application Support/Code/User/settings.json".source =
    #   ../dotfiles/vscode/settings.json;
    # "/Users/${username}/Library/Application Support/Code/User/keybindings.json".source =
    #   ../dotfiles/vscode/keybindings.json;
    # "/Users/${username}/Library/Application Support/Code/User/mcp.json".source =
    #   ../dotfiles/vscode/mcp.json;
    # "/Users/${username}/Library/Application Support/Code/User/prompts" = {
    #   source = ../dotfiles/vscode/prompts;
    #   recursive = true;
    # };
    # "/Users/${username}/Library/Application Support/Code/User/snippets" = {
    #   source = ../dotfiles/vscode/snippets;
    #   recursive = true;
    # };
  };
}
