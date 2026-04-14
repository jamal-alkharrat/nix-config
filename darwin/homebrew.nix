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
    ]; # GUI Apps
    brews = [
      "tailscale"
    ]; # CLI Tools
    #taps = [
    #];
    user = "jamalalkharrat";
  };
}