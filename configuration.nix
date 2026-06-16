#          ▗▄▄▄       ▗▄▄▄▄    ▄▄▄▖             diskutabel@nixos
#          ▜███▙       ▜███▙  ▟███▛             ----------------
#           ▜███▙       ▜███▙▟███▛              OS: NixOS 26.11 (Zokor) x86_64
#            ▜███▙       ▜██████▛               Host: MS-7D53 (1.0)
#     ▟█████████████████▙ ▜████▛     ▟▙         Kernel: Linux 6.18.26
#    ▟███████████████████▙ ▜███▙    ▟██▙        Packages: 1657 (nix-system), 869 (nix-user)
#           ▄▄▄▄▖           ▜███▙  ▟███▛        Shell: bash 5.3.9
#          ▟███▛             ▜██▛ ▟███▛         DE: KDE Plasma 6.6.5
#         ▟███▛               ▜▛ ▟███▛          WM: KWin (Wayland)
#▟███████████▛                  ▟██████████▙    WM Theme: WhiteSur-dark
#▜██████████▛                  ▟███████████▛    Theme: Breeze (WhiteSurDark) [Qt]
#      ▟███▛ ▟▙               ▟███▛             CPU: AMD Ryzen 7 5800X (16) @ 4.85 GHz
#     ▟███▛ ▟██▙             ▟███▛              GPU: AMD Radeon RX 7900 XT [Discrete]
#    ▟███▛  ▜███▙           ▝▀▀▀▀               Locale: en_US.UTF-8
#    ▜██▛    ▜███▙ ▜██████████████████▛         
#     ▜▛     ▟████▙ ▜████████████████▛          
#           ▟██████▙         ▜███▙              
#          ▟███▛▜███▙         ▜███▙             
#         ▟███▛  ▜███▙         ▜███▙            
#         ▝▀▀▀    ▀▀▀▀▘         ▀▀▀▘            
#                                               
#                                               
#                                               
#                                               
#                                               

{ config, pkgs, inputs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader. this is important!!
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # AMD GPU
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];

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

  services.xserver = {
    enable = true;
    xkb = {
      layout = "de";
      variant = "";
    };
    videoDrivers = [ "amdgpu" ];
  };
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.printing.enable = true;
  services.mullvad-vpn.enable = true;

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # LACT Daemon  i forgor what this was lowk something something hardware gpu prop
  systemd.services.lactd = {
    description = "AMDGPU Control Daemon";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
  };

  hardware.cpu.amd.updateMicrocode = true;

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/3e40cdde-ee68-4b7e-a012-5d96bdef2c6a";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024; # 16GB
  }];

  programs.hyprland = {
   enable = true;
    withUWSM = true;   # recommended session manager wrapper
   xwayland.enable = true;
  };
  users.users.diskutabel = {
    isNormalUser = true;
    description = "diskutabel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      vesktop
      prismlauncher
      btop
      spotify
      kitty
      lug-helper
      inputs.nix-citizen.packages.x86_64-linux.rsi-launcher
      nodejs_22
      claude-code
      jetbrains.idea
      wineWow64Packages.stable
      winetricks
      keepassxc
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  programs.firefox.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://nix-citizen.cachix.org" ];
    trusted-public-keys = [ "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo=" ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vscode
    git
    wget
    curl
    unzip
    p7zip
    file
    tree
    fastfetch
    ripgrep
    fd
    mpv
    vlc
    radeontop
    lact
    mesa-demos
    vulkan-tools
    pciutils

    #hyprland shit bc it doesnt ship with it on default :c

    # Session glue
    hyprpolkitagent      # GUI password prompts for privileged actions
    xdg-utils            # xdg-open and friends
    wl-clipboard         # wl-copy / wl-paste
    cliphist             # clipboard history

    # UI components
    waybar               # status bar
    fuzzel               # app launcher (lighter than wofi  )
    dunst                # notification daemon
    awww                 # wallpaper daemon (or hyprpaper)

    # Lock + idle
    hyprlock             # screen locker
    hypridle             # auto-lock / screen-off

    # Screenshots
    grim                 # screenshot
    slurp                # region select
    hyprshot             # convenient wrapper around grim+slurp

    
    brightnessctl        # backlight keys
    playerctl            # media play/pause keys
    pamixer              # CLI volume (for volume keybinds)
    pavucontrol          # graphical audio mixer
    networkmanagerapplet # nm-applet wifi tray icon
    nwg-look             # GTK theme settings GUI
    wlogout  
    blueman 

    # BlackNode rice deps
    rofi               
    libnotify   
    zsh
  ];

fonts.packages = with pkgs; [
  nerd-fonts.jetbrains-mono
  noto-fonts
  noto-fonts-color-emoji
];

  system.stateVersion = "25.11";
}

# merken du bastard

# sudo git add -A
# sudo git commit -m "your message here"
# sudo git push

# sudo nix flake update
# sudo nixos-rebuild switch --flake .
