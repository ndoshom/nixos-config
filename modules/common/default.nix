# modules/common/default.nix
{ config, pkgs, ... }:
{
  # ── Locale & time ──────────────────────────────────────────────────────────
  time.timeZone               = "Africa/Dar_es_salaam";          # ← set your timezone
  i18n.defaultLocale          = "en_US.UTF-8";

  # ── Nix settings ───────────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store   = true;
    };
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # ── Networking ─────────────────────────────────────────────────────────────
  networking.networkmanager.enable = true;

  # ── Base packages ──────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git curl wget vim htop tmux unzip rsync
  ];

  # ── User: ns ───────────────────────────────────────────────────────────────
  users.users.ns = {
    isNormalUser   = true;
    extraGroups    = [ "wheel" "networkmanager" ];
    shell          = pkgs.bash;
    # Set an initial hashed password with:
    #   mkpasswd -m sha-512 'yourpassword'
    # hashedPassword = "$6$...";
  };

  # Allow passwordless sudo for wheel (remove in production)
  security.sudo.wheelNeedsPassword = false;

  # ── SSH ────────────────────────────────────────────────────────────────────
  services.openssh = {
    enable                 = true;
    settings = {
      PermitRootLogin      = "no";
      PasswordAuthentication = false;   # key-only; see home-manager for keys
    };
  };

  # ── Firewall ───────────────────────────────────────────────────────────────
  networking.firewall = {
    enable          = true;
    allowedTCPPorts = [ 22 ];
  };
}
