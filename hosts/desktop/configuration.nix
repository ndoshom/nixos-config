# hosts/desktop/configuration.nix
{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/desktop
  ];

  networking.hostName = "nixos-desktop";
  networking.hostId   = "fd82c582";         # ← REPLACE

  boot = {
    loader.systemd-boot.enable      = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems             = [ "zfs" ];
    zfs.devNodes                     = "/dev/disk/by-id";
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot = {
      enable  = true;
      frequent = 4;
      hourly   = 24;
      daily    = 7;
    };
  };

  system.stateVersion = "24.11";
}
