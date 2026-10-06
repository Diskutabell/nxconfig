{ pkgs, ... }:

let
  sddm-lock-theme = pkgs.runCommandLocal "sddm-lock-theme" { } ''
    mkdir -p "$out/share/sddm/themes/lock"
    cp -r ${../themes/sddm-lock}/. "$out/share/sddm/themes/lock/"
  '';

  sddm-setup = pkgs.writeShellApplication {
    name = "sddm-setup";
    runtimeInputs = with pkgs; [ xrandr gnugrep gawk coreutils findutils imagemagick ];
    bashOptions = [ ];
    text = builtins.readFile ./sddm-setup.sh;
  };
in
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.xserver = {
    enable = true;
    xkb.layout = "de";
    videoDrivers = [ "amdgpu" ];
  };

  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "lock";
    extraPackages = with pkgs; [ qt6.qtmultimedia qt6.qtsvg ];
    settings = {
      General.InputMethod = "";
      General.GreeterEnvironment = "QML_XHR_ALLOW_FILE_READ=1";
      X11.EnableHiDPI = false;
    };
    setupScript = "${sddm-setup}/bin/sddm-setup";
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  qt = {
    enable = true;
    platformTheme = "kde";
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  users.users.diskutabel.packages = [ pkgs.kitty ];

  environment.systemPackages = with pkgs; [
    sddm-lock-theme

    # hyprland session
    hyprpolkitagent
    hyprlock
    hypridle
    quickshell
    qt6.qtmultimedia
    matugen
    awww
    mpvpaper
    rofi
    wlogout
    swayosd
    libnotify
    xdg-utils
    socat
    cava

    # clipboard / screenshots
    wl-clipboard
    cliphist
    grim
    slurp
    hyprshot
    satty

    # audio / brightness / network
    pulseaudio # pactl, used by hypr scripts
    pamixer
    pavucontrol
    playerctl
    brightnessctl
    networkmanagerapplet

    # theming / files
    nwg-look
    kdePackages.breeze-icons
    kdePackages.kio-extras
    nautilus
  ];
}
