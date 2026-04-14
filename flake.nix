{
  description = "MacOS configuration using nix-darwin and home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{   self, nix-darwin, nixpkgs, home-manager, ... }:
  let
    configuration = { pkgs, ... }: {

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs;
        [ 
          home-manager
        ];

      homebrew = {
          enable = true;
          onActivation = {
            autoUpdate = true;
            upgrade = true;
            cleanup = "zap";
          };
          casks = [ 
            "hyperkey"
            "linearmouse"
            "typewhisper/tap/typewhisper"
            "ghostty"
            "dockdoor"
            "shottr"
            "middleclick"
            "mos"
            "notion"
            "telegram"
          ]; # GUI Apps
          #brews = [ 
          #]; # CLI Tools
          #taps = [
          #];
          user = "jamalalkharrat";
        };

      nixpkgs.config = {
        allowUnfree = true;
      };
      
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

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

      users.users.jamalalkharrat = {
        name = "jamalalkharrat";
        home = "/Users/jamalalkharrat";
      };

      home-manager.users.jamalalkharrat = { pkgs, ... }: {
        imports = [ ./home.nix ];
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#mac
    darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        inputs.home-manager.darwinModules.home-manager
       ];
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    };
  };
}
