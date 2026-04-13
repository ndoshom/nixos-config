# hosts/desktop/disko.nix  — identical pool layout; tune sizes as needed
{ ... }:
{
  disko.devices = {
    disk.main = {
      type   = "disk";
      device = "/dev/sda";

      content = {
        type = "gpt";
        partitions = {
          ESP  = { size = "512M"; type = "EF00"; content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; }; };
          swap = { size = "16G"; content = { type = "swap"; }; };
          zfs  = { size = "100%"; content = { type = "zfs"; pool = "zroot"; }; };
        };
      };
    };

    zpool.zroot = {
      type = "zpool";
      options      = { ashift = "12"; autotrim = "on"; };
      rootFsOptions = { compression = "zstd"; "com.sun:auto-snapshot" = "false"; mountpoint = "none"; xattr = "sa"; acltype = "posixacl"; };

      datasets = {
        "local"        = { type = "zfs_fs"; options.mountpoint = "none"; };
        "local/root"   = { type = "zfs_fs"; options.mountpoint = "legacy"; mountpoint = "/"; };
        "local/nix"    = { type = "zfs_fs"; options.mountpoint = "legacy"; mountpoint = "/nix"; };
        "local/var"    = { type = "zfs_fs"; options.mountpoint = "legacy"; mountpoint = "/var"; };
        "safe"         = { type = "zfs_fs"; options.mountpoint = "none"; };
        "safe/home"    = { type = "zfs_fs"; options.mountpoint = "legacy"; mountpoint = "/home"; };
        "safe/persist" = { type = "zfs_fs"; options.mountpoint = "legacy"; mountpoint = "/persist"; };
      };
    };
  };
}
