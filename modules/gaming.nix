{ pkgs, inputs, ... }:

let
  rsi-launcher = pkgs.symlinkJoin {
    name = "rsi-launcher";
    paths = [ inputs.nix-citizen.packages.${pkgs.stdenv.hostPlatform.system}.rsi-launcher ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/rsi-launcher --set XDG_SESSION_TYPE x11 --set PULSE_LATENCY_MSEC 60
    '';
  };
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  boot.kernelModules = [ "ntsync" ];

  users.users.diskutabel.packages = with pkgs; [
    prismlauncher
    jdk25
    lug-helper
    rsi-launcher
    wineWow64Packages.stable
    winetricks
  ];
}
