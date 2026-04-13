# nixos-config

A NixOS flake managing two hosts with ZFS root, Home Manager for user `ns`, and GitHub-bootstrapped install.

```
nixos-config/
├── flake.nix
├── install.sh                  # one-liner bootstrap from minimal ISO
├── hosts/
│   ├── server/
│   │   ├── configuration.nix   # server-specific NixOS config
│   │   ├── disko.nix           # ZFS partition layout
│   │   └── hardware-configuration.nix  # generated on first install
│   └── desktop/
│       ├── configuration.nix   # desktop-specific NixOS config
│       ├── disko.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── common/                 # shared: nix settings, user ns, SSH, firewall
│   ├── server/                 # Jellyfin + Nextcloud + Nginx reverse proxy
│   └── desktop/                # KDE Plasma 6 + audio + fonts
└── home-manager/
    └── ns/
        └── home.nix            # git, ssh, bash, tmux, neovim, packages
```

---

## Quick start — install from minimal ISO

```bash
# Boot the NixOS minimal ISO, then:
bash <(curl -sL https://raw.githubusercontent.com/YOUR_USER/nixos-config/main/install.sh)
# For desktop:
bash <(curl -sL https://raw.githubusercontent.com/YOUR_USER/nixos-config/main/install.sh) desktop
```

The script will:
1. Clone this repo
2. Partition & format `/dev/sda` with ZFS using disko
3. Generate `hardware-configuration.nix`
4. Run `nixos-install`
5. Copy the flake to `/mnt/etc/nixos`

---

## Before first commit — things to customise

| File | What to change |
|------|---------------|
| `hosts/server/configuration.nix` | `networking.hostId` (run: `head -c4 /dev/urandom \| od -A none -t x4`) |
| `hosts/desktop/configuration.nix` | `networking.hostId` |
| `hosts/*/disko.nix` | `device` if not `/dev/sda` |
| `modules/common/default.nix` | `time.timeZone`, `users.users.ns.hashedPassword` |
| `modules/server/default.nix` | Domain names, ACME email |
| `home-manager/ns/home.nix` | SSH public keys, git name/email |
| `install.sh` | `FLAKE_REPO` URL |

---

## Day-to-day usage

```bash
# Rebuild & switch (run on the target machine)
sudo nixos-rebuild switch --flake /etc/nixos#server
sudo nixos-rebuild switch --flake /etc/nixos#desktop

# Update flake inputs
nix flake update /etc/nixos

# Home Manager standalone rebuild (if needed)
home-manager switch --flake /etc/nixos#ns
```

---

## Server services

| Service    | Internal port | Public URL |
|------------|--------------|------------|
| Jellyfin   | 8096         | https://jellyfin.example.com |
| Nextcloud  | (unix socket)| https://nextcloud.example.com |

Nginx terminates TLS via Let's Encrypt (ACME). Make sure DNS A records
point to the server before enabling ACME.

### Nextcloud admin password

```bash
# On the server, create the secret file before first activation:
sudo mkdir -p /persist/secrets
echo -n 'your-strong-password' | sudo tee /persist/secrets/nextcloud-admin-pass
sudo chmod 600 /persist/secrets/nextcloud-admin-pass
```

---

## ZFS dataset layout

```
zroot
├── local/
│   ├── root   → /
│   ├── nix    → /nix
│   └── var    → /var
└── safe/
    ├── home   → /home
    └── persist→ /persist
```

`safe/` datasets are auto-snapshotted. `/persist` is the recommended place
for stateful data (secrets, databases, media libraries).

---

## SSH access

Password authentication is **disabled**. Add your public key to
`home-manager/ns/home.nix` under `home.file.".ssh/authorized_keys"` before
installation, or after install:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub ns@<server-ip>
```
# nixos-config
