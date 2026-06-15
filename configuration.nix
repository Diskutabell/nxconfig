#          ▗▄▄▄       ▗▄▄▄▄    ▄▄▄▖             diskutabel@nixos
#          ▜███▙       ▜███▙  ▟███▛             ----------------
#           ▜███▙       ▜███▙▟███▛              OS: NixOS 26.11 (Zokor) x86_64
#            ▜███▙       ▜██████▛               Host: MS-7D53 (1.0)
#     ▟█████████████████▙ ▜████▛     ▟▙         Kernel: Linux 6.18.26
#    ▟███████████████████▙ ▜███▙    ▟██▙        Uptime: 1 hour, 25 mins
#           ▄▄▄▄▖           ▜███▙  ▟███▛        Packages: 1657 (nix-system), 869 (nix-user)
#          ▟███▛             ▜██▛ ▟███▛         Shell: bash 5.3.9
#         ▟███▛               ▜▛ ▟███▛          Display (Q27G4ZR): 2560x1440 in 27", 144 Hz [External] *
#▟███████████▛                  ▟██████████▙    Display (HP 27m): 1920x1080 in 27", 60 Hz [External]
#▜██████████▛                  ▟███████████▛    DE: KDE Plasma 6.6.5
#      ▟███▛ ▟▙               ▟███▛             WM: KWin (Wayland)
#     ▟███▛ ▟██▙             ▟███▛              WM Theme: WhiteSur-dark
#    ▟███▛  ▜███▙           ▝▀▀▀▀               Theme: Breeze (WhiteSurDark) [Qt]
#    ▜██▛    ▜███▙ ▜██████████████████▛         Icons: WhiteSur-dark [Qt], WhiteSur-dark [GTK2/3/4]
#     ▜▛     ▟████▙ ▜████████████████▛          Font: Noto Sans (10pt) [Qt], Noto Sans (10pt) [GTK2/3/4]
#           ▟██████▙         ▜███▙              Cursor: WhiteSur (24px)
#          ▟███▛▜███▙         ▜███▙             Terminal: konsole 26.4.0
#         ▟███▛  ▜███▙         ▜███▙            CPU: AMD Ryzen 7 5800X (16) @ 4.85 GHz
#         ▝▀▀▀    ▀▀▀▀▘         ▀▀▀▘            GPU: AMD Radeon RX 7900 XT [Discrete]
#                                               Memory: 6.52 GiB / 31.27 GiB (21%)
#                                               Swap: 4.00 KiB / 16.00 GiB (0%)
#                                               Disk (/): 305.37 GiB / 914.83 GiB (33%) - ext4
#                                               Disk (/mnt/data): 431.03 GiB / 1.79 TiB (24%) - ext4
#                                               Locale: en_US.UTF-8
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

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };
  console.keyMap = "de";
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

  # AMD GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd     
      libva-vdpau-driver      
      libvdpau-va-gl
    ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  systemd.tmpfiles.rules = [
    "w /sys/class/drm/card1/device/power_dpm_force_performance_level - - - - high"
  ];

  # LACT Daemon  i forgor what this was lowk something something hardware
  systemd.services.lactd = {
    description = "AMDGPU Control Daemon";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/3e40cdde-ee68-4b7e-a012-5d96bdef2c6a";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };


  hardware.cpu.amd.updateMicrocode = true;

  users.users.diskutabel = {
    isNormalUser = true;
    description = "diskutabel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      vesktop
      prismlauncher
      btop
      mullvad
      mullvad-vpn
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

# merken du bastard

# sudo git add -A
# sudo git commit -m "your message here"
# sudo git push

# sudo nix flake update
# sudo nixos-rebuild switch --flake .

  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024; # 16GB
  }];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;       
    dedicatedServer.openFirewall = true;  
    gamescopeSession.enable = true;       
  };

 nix.settings = {
  substituters = [ "https://nix-citizen.cachix.org" ];
  trusted-public-keys = [ "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo=" ];
  experimental-features = [ "nix-command" "flakes" ];
};
  programs.gamemode.enable = true;  

 
  programs.firefox.enable = true;

  
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

  
  ];

  system.stateVersion = "25.11";
}