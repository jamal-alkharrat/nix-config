{ config, ... }:
let
  username = (import ../common/username.nix).username;
in
{
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets.fints_password = {};

  home.sessionVariables = {
    FINTS_PASSWORD = "$(cat ${config.sops.secrets.fints_password.path})";
  };
}