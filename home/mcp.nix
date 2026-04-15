{
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
}