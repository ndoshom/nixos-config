# modules/desktop/default.nix
{ config, pkgs, ... }:
{
  # ── Display manager & KDE Plasma ────────────────────────────────────────────
  services.displayManager.sddm = {
    enable    = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;

  # ── Pipewire audio ───────────────────────────────────────────────────────────
  security.rtkit.enable   = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;
  };

  # ── Printing ─────────────────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── Bluetooth ────────────────────────────────────────────────────────────────
  hardware.bluetooth.enable      = true;
  services.blueman.enable        = true;

  # ── Fonts ────────────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
  ];

  # ── Desktop packages ─────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    firefox
    thunderbird
    kate
    ark
    okular
    spectacle
    vlc
    libreoffice-qt6-fresh
    gimp
    vscode
  ];

  # ── XDG portals ──────────────────────────────────────────────────────────────
  xdg.portal = {
    enable       = true;
    extraPortals = [ pkgs.xdg-desktop-portal-kde ];
  };
}
