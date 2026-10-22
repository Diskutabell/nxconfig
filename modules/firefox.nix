{ ... }:

{
  programs.firefox = {
    enable = true;
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;

      "browser.contentblocking.category" = "strict";
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
      "privacy.trackingprotection.fingerprinting.enabled" = true;
      "privacy.trackingprotection.cryptomining.enabled" = true;
      "privacy.trackingprotection.emailtracking.enabled" = true;
      "privacy.fingerprintingProtection" = true;
      "privacy.fingerprintingProtection.pbmode" = true;
      "network.cookie.cookieBehavior" = 5;
      "privacy.query_stripping.enabled" = true;

      "media.peerconnection.ice.default_address_only" = true;
      "media.peerconnection.ice.no_host" = true;
    };
  };
}
