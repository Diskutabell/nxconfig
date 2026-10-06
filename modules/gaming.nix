{ pkgs, inputs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  users.users.diskutabel.packages = with pkgs; [
    prismlauncher
    lug-helper
    inputs.nix-citizen.packages.${pkgs.stdenv.hostPlatform.system}.rsi-launcher
    wineWow64Packages.stable
    winetricks
  ];
}
