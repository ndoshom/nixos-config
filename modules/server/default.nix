# modules/server/default.nix
{ config, pkgs, ... }:
{
  # ── Open HTTP/HTTPS ─────────────────────────────────────────────────────────
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # ── ACME / Let's Encrypt ────────────────────────────────────────────────────
  security.acme = {
    acceptTerms = true;
    defaults.email = "ndosho1@gmail.com";   # ← your email
  };

  # ── Nginx (reverse proxy) ───────────────────────────────────────────────────
  services.nginx = {
    enable              = true;
    recommendedGzipSettings    = true;
    recommendedOptimisation    = true;
    recommendedProxySettings   = true;
    recommendedTlsSettings     = true;

    # ── Jellyfin vhost ──────────────────────────────────────────────────────
    virtualHosts."jellyfin.nertbird.xyz" = {   # ← replace domain
      forceSSL     = true;
      enableACME   = true;

      locations."/" = {
        proxyPass       = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        extraConfig     = ''
          proxy_buffering off;
        '';
      };
    };

    # ── Nextcloud vhost ─────────────────────────────────────────────────────
    virtualHosts."nextcloud.nertbird.xyz" = {  # ← replace domain
      forceSSL   = true;
      enableACME = true;
    };
  };

  # ── Jellyfin ────────────────────────────────────────────────────────────────
  services.jellyfin = {
    enable    = true;
    openFirewall = false;   # nginx handles exposure
    user      = "jellyfin";
    group     = "jellyfin";
  };

  # ── Nextcloud ───────────────────────────────────────────────────────────────
  services.nextcloud = {
    enable       = true;
    hostName     = "nextcloud.nertbird.xyz";   # ← replace domain
    package      = pkgs.nextcloud30;

    config = {
      adminpassFile = "/persist/secrets/nextcloud-admin-pass"; # create this file
      dbtype        = "pgsql";
    };

    database.createLocally = true;

    settings = {
      trusted_domains        = [ "nextcloud.example.com" ];
      default_phone_region   = "US";
      overwriteprotocol      = "https";
    };
  };

  # PostgreSQL (for Nextcloud)
  services.postgresql.enable = true;

  # ── Redis (Nextcloud cache) ─────────────────────────────────────────────────
  services.redis.servers.nextcloud = {
    enable = true;
    user   = "nextcloud";
    port   = 0;      # unix socket only
  };

  # Tell Nextcloud about Redis
  services.nextcloud.settings.redis = {
    host     = config.services.redis.servers.nextcloud.unixSocket;
    dbindex  = 0;
    timeout  = 1.5;
  };

  # ── Fail2ban ────────────────────────────────────────────────────────────────
  services.fail2ban = {
    enable = true;
    jails.sshd.settings = { enabled = true; };
  };
}
