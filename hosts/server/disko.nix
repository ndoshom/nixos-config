# hosts/server/disko.nix
# ---------------------------------------------------------------------------
# Targets /dev/sda for a fresh ZFS install.
# If you are installing into an existing partition (/dev/sda5) you must
# pre-format that partition as a LUKS container or ZFS pool manually, then
# point the pool's `disk` attribute at the vdev device.
#
# For a clean install on a dedicated disk, this creates:
#   sda1 — EFI  (512 MiB, vfat)
#   sda2 — swap (8 GiB)
#   sda3 — ZFS  (remainder)
# ---------------------------------------------------------------------------
{ ... }:
{
  disko.devices = {
    disk.main = {
      type   = "disk";
      device = "/dev/sda";          # ← change to /dev/sdb etc. as needed

      content = {
        type = "gpt";
        partitions = {

          ESP = {
            size    = "512M";
            type    = "EF00";       # EFI System Partition
            content = {
              type   = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };

          swap = {
            size    = "8G";
            content = { type = "swap"; };
          };

          zfs = {
            size    = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };

    # ── ZFS pool & datasets ─────────────────────────────────────────────────
    zpool.zroot = {
      type = "zpool";

      options = {
        ashift        = "12";
        autotrim      = "on";
      };

      rootFsOptions = {
        compression   = "zstd";
        "com.sun:auto-snapshot" = "false";
        mountpoint    = "none";
        xattr         = "sa";
        acltype       = "posixacl";
      };

      datasets = {
        "local"            = { type = "zfs_fs"; options.mountpoint = "none"; };
        "local/root"       = {
          type    = "zfs_fs";
          options = { mountpoint = "legacy"; };
          mountpoint = "/";
          # blank snapshot for impermanence (optional)
        };
        "local/nix"        = { type = "zfs_fs"; options.mountpoint = "legacy"; mountpoint = "/nix"; };
        "local/var"        = { type = "zfs_fs"; options.mountpoint = "legacy"; mountpoint = "/var"; };

        "safe"             = { type = "zfs_fs"; options.mountpoint = "none"; };
        "safe/home"        = { type = "zfs_fs"; options.mountpoint = "legacy"; mountpoint = "/home"; };
        "safe/persist"     = { type = "zfs_fs"; options.mountpoint = "legacy"; mountpoint = "/persist"; };
      };
    };
  };
}
