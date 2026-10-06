#          ▗▄▄▄       ▗▄▄▄▄    ▄▄▄▖             diskutabel@nixos
#          ▜███▙       ▜███▙  ▟███▛             ----------------
#           ▜███▙       ▜███▙▟███▛              OS: NixOS 26.11 (Zokor) x86_64
#            ▜███▙       ▜██████▛               Kernel: Linux 6.18.35
#     ▟█████████████████▙ ▜████▛     ▟▙         Packages: 1729 (nix-system), 866 (nix-user)
#    ▟███████████████████▙ ▜███▙    ▟██▙        Shell: bash 5.3.9
#           ▄▄▄▄▖           ▜███▙  ▟███▛        WM: Hyprland 0.55.3 (Wayland)
#          ▟███▛             ▜██▛ ▟███▛         Icons: WhiteSur-dark [GTK2/3/4]
#         ▟███▛               ▜▛ ▟███▛          Font: Noto Sans (10pt) [GTK2/3/4]
#▟███████████▛                  ▟██████████▙    Cursor: WhiteSur (24px)
#▜██████████▛                  ▟███████████▛
#      ▟███▛ ▟▙               ▟███▛
#     ▟███▛ ▟██▙             ▟███▛
#    ▟███▛  ▜███▙           ▝▀▀▀▀
#    ▜██▛    ▜███▙ ▜██████████████████▛         Terminal: kitty 0.47.2
#     ▜▛     ▟████▙ ▜████████████████▛          Terminal Font: JetBrainsMonoNF-Regular (12pt)
#           ▟██████▙         ▜███▙              CPU: AMD Ryzen 7 5800X (16) @ 4.85 GHz
#          ▟███▛▜███▙         ▜███▙             GPU: AMD Radeon RX 7900 XT [Discrete]
#         ▟███▛  ▜███▙         ▜███▙
#         ▝▀▀▀    ▀▀▀▀▘         ▀▀▀▘


{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/hardware.nix
    ./modules/desktop.nix
    ./modules/shell.nix
    ./modules/dev.nix
    ./modules/gaming.nix
    ./modules/virtualisation.nix
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
  console.keyMap = "de";

  users.users.diskutabel = {
    isNormalUser = true;
    description = "diskutabel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      vesktop
      spotify
      btop
      keepassxc
      obs-studio
      lufus
    ];
  };

  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.gui.enable = true;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    git
    gh
    wget
    curl
    unzip
    p7zip
    file
    tree
    fastfetch
    ripgrep
    fd
    jq
    bc
    psmisc
    inotify-tools
    python3
    mpv
    vlc
    ffmpeg
    imagemagick
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://nix-citizen.cachix.org" ];
    trusted-public-keys = [
      "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # DO NOT BUMP THIS.
  system.stateVersion = "25.11";
}


# merken du bastard

# git add -A
# git commit -m "your message here"
# git push

# sudo nix flake update
# sudo nixos-rebuild switch --flake .
# sudo chown -R diskutabel:users /etc/nixos