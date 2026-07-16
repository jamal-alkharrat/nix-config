{
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
      "raycast"
      "typewhisper/tap/typewhisper"
      "ghostty"
      "dockdoor"
      "shottr"
      "middleclick"
      "mos"
      "steam"
      "notion"
      "telegram"
      "whatsapp"
      "tailscale-app"
      "twingate"
      "rectangle"
      "visual-studio-code"
      "docker-desktop"
      "steam"
      "discord"
    ]; # GUI Apps
    brews = [
      "typst"
      "just"
    ]; # CLI Tools
    taps = [
      "typewhisper/tap"
    ];

    user = "jamalalkharrat";
  };
}
