{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.librewolf.override {
      extraPrefs = ''
        lockPref("privacy.resistFingerprinting", true);
        lockPref("privacy.resistFingerprinting.letterboxing", true);
        lockPref("privacy.resistFingerprinting.letterboxing.dimensions", "1920x1080,1600x900,1366x768,1280x720,1024x768,800x600,640x480");
        lockPref("privacy.spoof_english", 2);
        lockPref("webgl.disabled", true);
        lockPref("font.system.whitelist", "DejaVu Sans, DejaVu Serif, DejaVu Sans Mono, Twemoji Mozilla");
      '';
    })
  ];
}
