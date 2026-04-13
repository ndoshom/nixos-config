# home-manager/ns/home.nix
{ config, pkgs, ... }:
{
  home.username = "ns";
  home.homeDirectory = "/home/ns";
  home.stateVersion  = "24.11";

  # ── SSH ───────────────────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";

    matchBlocks = {
      # Example entry — add your own servers here
      "server" = {
        hostname     = "192.168.8.20";  # ← replace
        user         = "ns";
      };
    };
  };

  # Authorized keys for inbound SSH (picked up by NixOS openssh)
  home.file.".ssh/authorized_keys".text = ''
  '';

  # ── Git ───────────────────────────────────────────────────────────────────
  programs.git = {
    enable    = true;
    userName  = "ndoshom";
    userEmail = "ndosho1@gmail.com";   # ← replace

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase        = false;
      core.editor        = "vim";
    };

    aliases = {
      st  = "status";
      lg  = "log --oneline --graph --decorate --all";
      co  = "checkout";
    };
  };

  # ── Shell ─────────────────────────────────────────────────────────────────
  programs.bash = {
    enable = true;
    shellAliases = {
      ll   = "ls -alh";
      ".." = "cd ..";
      nrs  = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
      nrb  = "sudo nixos-rebuild boot --flake /etc/nixos#$(hostname)";
    };
    initExtra = ''
      # colour prompt
      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    '';
  };

  # ── Neovim ───────────────────────────────────────────────────────────────
  programs.neovim = {
    enable        = true;
    defaultEditor = true;
    vimAlias      = true;
  };

  # ── tmux ─────────────────────────────────────────────────────────────────
  programs.tmux = {
    enable       = true;
    shortcut     = "a";
    terminal     = "screen-256color";
    historyLimit = 10000;
    extraConfig  = ''
      set -g mouse on
      set -g base-index 1
      setw -g pane-base-index 1
    '';
  };

  # ── Packages ─────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    fzf
    jq
    tree
    htop
  ];

  programs.home-manager.enable = true;
}
