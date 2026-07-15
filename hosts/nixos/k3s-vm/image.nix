{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/image/image-format-qcow2.nix")
  ];

  # Image format config — filesystem, boot, partitioning
  image = {
    baseName = "k3s-vm-nixos";
    device = "/dev/sda";
    partitionTableType = "efi";
    partitionTable = {
      espSize = "512M";
      bootSize = "0";
      rootSize = "55.5G";
      swapSize = "4G";
    };
  };

  # Override hardware config — no auto-generated stuff needed
  boot.loader.grub.devices = [ "/dev/sda" ];
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/dev/disk/by-label/swap";
  }];
}
