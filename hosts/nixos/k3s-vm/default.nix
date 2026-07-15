# K3s VM - NixOS configuration
# This file is the entry point for the NixOS configuration.
# It's referenced by flake.nix as the main module.
{ config, pkgs, lib, ... }:

{
  imports = [
    ./configuration.nix
  ];
}
