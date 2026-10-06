{ pkgs, ... }:

{
  # Bootloader. this is important!!
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # amdgpu link-training errors spam the LUKS prompt; they're harmless.
  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" "loglevel=3" "rd.udev.log_level=3" ];
  boot.initrd.verbose = false;

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
  services.hardware.openrgb.enable = true;
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
