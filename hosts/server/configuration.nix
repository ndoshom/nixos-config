# hosts/server/configuration.nix
{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/server
  ];

  networking.hostName = "nixos-server";

  # ZFS host ID — generate with: head -c4 /dev/urandom | od -A none -t x4 | tr -d ' '
  networking.hostId = "fd82c582";           # ← REPLACE with your own

  boot = {
    loader.systemd-boot.enable      = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems             = [ "zfs" ];
    zfs.devNodes                     = "/dev/disk/by-id";
  };

  # ZFS auto-scrub & snapshots
  services.zfs = {
    autoScrub.enable   = true;
    autoSnapshot = {
      enable   = true;
      frequent = 4;
      hourly   = 24;
      daily    = 7;
      weekly   = 4;
      monthly  = 12;
    };
  };

  system.stateVersion = "24.11";
}
