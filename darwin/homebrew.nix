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
      # "visual-studio-code"
    ]; # GUI Apps
    # brews = [
    # ]; # CLI Tools
    taps = [
      "typewhisper/tap"
    ];

    user = "jamalalkharrat";
  };
}
