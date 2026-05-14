# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{ config, pkgs, inputs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
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

  # GPU
  systemd.tmpfiles.rules = [
    "w /sys/class/drm/card1/device/power_dpm_force_performance_level - - - - high"
  ];

  # LACT Daemon 
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

  # AMD CPU microcode
  hardware.cpu.amd.updateMicrocode = true;

  # User
  users.users.diskutabel = {
    isNormalUser = true;
    description = "diskutabel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # User-specific apps
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
      nodejs_20
      claude-code
    ];
  };

  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024; # 16GB
  }];

  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;       # for Steam Remote Play
    dedicatedServer.openFirewall = true;  # for hosting game servers
    gamescopeSession.enable = true;       # gamescope session option in SDDM
  };

 nix.settings = {
  substituters = [ "https://nix-citizen.cachix.org" ];
  trusted-public-keys = [ "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo=" ];
  experimental-features = [ "nix-command" "flakes" ];
};
  programs.gamemode.enable = true;  

  # Firefox
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Editors / dev
    vscode
    git

    # Shell / terminal QoL
    wget
    curl
    unzip
    p7zip
    file
    tree
    fastfetch       # like neofetch but maintained
    ripgrep         # fast grep replacement
    fd              # fast find replacement
    bat             # cat with syntax highlighting
    eza             # ls replacement

    # Media
    mpv
    vlc

    # GPU / System Monitoring
    radeontop       # AMD GPU Monitor
    lact            # AMD GPU Control GUI
    mesa-demos      # glxinfo, glxgears
    vulkan-tools    # vulkaninfo, vkcube
    pciutils        # lspci

    # Misc
    htop
  ];

  system.stateVersion = "25.11";
}