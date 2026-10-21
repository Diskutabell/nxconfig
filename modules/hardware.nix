{ pkgs, ... }:

{
  # Bootloader. this is important!!
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = null;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    configurationLimit = 10;
    theme = ../themes/marathon-newcascadia;
    font = "${../themes/marathon-newcascadia}/Interference-16.pf2";
    gfxmodeEfi = "2560x1440,auto";
    splashImage = "${../themes/marathon-newcascadia}/background.jpg";
    extraEntries = ''
      menuentry "UEFI Firmware Settings" --class efi {
        fwsetup
      }
    '';
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" "loglevel=3" "rd.udev.log_level=3" ];
  boot.initrd.verbose = false;
  boot.initrd.systemd.enable = true;

  boot.plymouth = {
    enable = true;
    theme = "marathon-newcascadia";
    themePackages = [
      (pkgs.runCommand "plymouth-marathon-newcascadia" { } ''
        mkdir -p $out/share/plymouth/themes
        cp -r ${../themes/marathon-newcascadia-plymouth} $out/share/plymouth/themes/marathon-newcascadia
        chmod -R u+w $out/share/plymouth/themes/marathon-newcascadia
        substituteInPlace $out/share/plymouth/themes/marathon-newcascadia/marathon-newcascadia.plymouth --replace-fail "@out@" "$out"
      '')
    ];
    font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSansMono.ttf";
  };

  hardware.cpu.amd.updateMicrocode = true;

  hardware.amdgpu = {
    initrd.enable = true;
    opencl.enable = true;
    overdrive = {
      enable = true; # needed for LACT
      ppfeaturemask = "0xffffffff";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ libvdpau-va-gl libva-utils ];
  };

  services.lact.enable = true;
  services.hardware.openrgb = {
    enable = true;
    startupProfile = "PINKKKK"; # apply on boot, otherwise the Quadcast S falls back to its rainbow
  };
  services.power-profiles-daemon.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.samsung-unified-linux-driver_1_00_37 ];
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/3e40cdde-ee68-4b7e-a012-5d96bdef2c6a";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024;
  }];

  environment.systemPackages = with pkgs; [
    radeontop
    mesa-demos
    vulkan-tools
    pciutils
    iw
  ];
}
