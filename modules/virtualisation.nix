{
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true; # TPM 2.0 for Windows 11
  };
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  users.users.diskutabel.extraGroups = [ "libvirtd" ];
}
