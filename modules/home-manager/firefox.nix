{ inputs, config, pkgs, ... }:

# I might have stolen this from
# https://github.com/gvolpe/nix-config/blob/ba66185bb49f549f7ff5eef632a999016f912832/home/programs/browsers/firefox.nix
# Thanks!
let
  # disable the annoying floating icon with camera and mic when on a call
  disableWebRtcIndicator = ''
    #webrtcIndicator {
      display: none;
    }
  '';

  userChrome = disableWebRtcIndicator;

  # ~/.mozilla/firefox/PROFILE_NAME/prefs.js | user.js
  settings = {
    "app.normandy.first_run" = false;
    "app.shield.optoutstudies.enabled" = false;

    "OverrideFirstRunPage" = "";
    "OverridePostUpdatePage" = "";
    "DisplayBookmarksToolbar" = "never"; # alternatives: "always" or "newtab"
    "DisplayMenuBar" = "default-off"; # alternatives: "always", "never" or "default-on"
    "SearchBar" = "unified"; # alternative: "separate"

    # disable updates (pretty pointless with nix)
    "app.update.channel" = "default";

    "browser.contentblocking.category" = "strict"; # "strict"
    "browser.ctrlTab.recentlyUsedOrder" = false;

    "browser.download.useDownloadDir" = false;
    "browser.download.viewableInternally.typeWasRegistered.svg" = true;
    "browser.download.viewableInternally.typeWasRegistered.webp" = true;
    "browser.download.viewableInternally.typeWasRegistered.xml" = true;

    "browser.link.open_newwindow" = false;

    "browser.search.region" = "NL";
    "browser.search.widget.inNavBar" = true;

    "browser.shell.checkDefaultBrowser" = false;
    "browser.startup.homepage" = "https://nixos.org";
    "browser.tabs.loadInBackground" = true;
    "browser.urlbar.placeholderName" = "DuckDuckGo";
    "browser.urlbar.showSearchSuggestionsFirst" = false;

    # disable all the annoying quick actions
    "browser.urlbar.quickactions.enabled" = false;
    "browser.urlbar.quickactions.showPrefs" = false;
    "browser.urlbar.shortcuts.quickactions" = false;
    "browser.urlbar.suggest.quickactions" = false;

    "distribution.searchplugins.defaultLocale" = "en-US";

    "doh-rollout.balrog-migration-done" = true;
    "doh-rollout.doneFirstRun" = true;

    "dom.forms.autocomplete.formautofill" = false;

    "general.autoScroll" = true;
    "general.useragent.locale" = "en-US";

    "extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";

    "extensions.extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";
    "extensions.update.enabled" = false;

    "print.print_footerleft" = "";
    "print.print_footerright" = "";
    "print.print_headerleft" = "";
    "print.print_headerright" = "";

    "privacy.donottrackheader.enabled" = true;

    # Yubikey
    "security.webauth.u2f" = true;
    "security.webauth.webauthn" = true;
    "security.webauth.webauthn_enable_softtoken" = true;
    "security.webauth.webauthn_enable_usbtoken" = true;

    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  };

  mimeTypes = [
    "application/json"
    "application/pdf"
    "application/x-extension-htm"
    "application/x-extension-html"
    "application/x-extension-shtml"
    "application/x-extension-xhtml"
    "application/x-extension-xht"
    "application/xhtml+xml"
    "text/html"
    "text/xml"
    "x-scheme-handler/about"
    "x-scheme-handler/ftp"
    "x-scheme-handler/http"
    "x-scheme-handler/unknown"
    "x-scheme-handler/https"
  ];

  extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
    bitwarden
    darkreader
    ff2mpv
    # auto-accepts cookies, use only with privacy-badger & ublock-origin
    i-dont-care-about-cookies
    link-cleaner
    privacy-badger
    to-deepl
    ublock-origin
    unpaywall
    vimium
  ];
in
{
  home.packages = with pkgs; [ firefox ];

  home.sessionVariables.BROWSER = "firefox";

  xdg.mimeApps.defaultApplications = builtins.listToAttrs (map (mimeType: {
        name = mimeType;
        value = ["firefox.desktop"];
        })
      mimeTypes);

  programs.firefox = {
    enable = true;

    package = if pkgs.stdenv.isLinux then pkgs.firefox else pkgs.firefox-bin;

    profiles = {
      default = {
        id = 0;
        name = "privacy-friendly";
        inherit settings userChrome extensions;
      };

      shit = {
        name = "trade-privacy-for-convenience";
        id = 1;
        inherit extensions;
      };
    };
  };
}
