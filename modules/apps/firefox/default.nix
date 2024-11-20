{
  firefox-addons,
  lib,
  config,
  pkgs,
  home-manager,
  username,
  ...
}:
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
  settings =
    {
      # Fonts
      "font.name.monospace.x-western" = "${lib.head config.fonts.fontconfig.defaultFonts.monospace}";
      "font.name.sans-serif.x-western" = "${lib.head config.fonts.fontconfig.defaultFonts.sansSerif}";
      "font.name.serif.x-western" = "${lib.head config.fonts.fontconfig.defaultFonts.serif}";

      "app.normandy.first_run" = false;
      "app.shield.optoutstudies.enabled" = false;

      "OverrideFirstRunPage" = "";
      "OverridePostUpdatePage" = "";
      "DisplayBookmarksToolbar" = "always"; # alternatives: "always" or "newtab"
      "DisplayMenuBar" = "default-off"; # alternatives: "always", "never" or "default-on"
      "SearchBar" = "unified"; # alternative: "separate"

      # disable updates (pretty pointless with nix)
      "app.update.channel" = "default";

      "browser.contentblocking.category" = "strict"; # "strict"
      "browser.ctrlTab.recentlyUsedOrder" = false;
      "browser.aboutConfig.showWarning" = false;
      "browser.toolbars.bookmarks.visibility" = "always";
      "browser.quitShortcut.disabled" = true; # Prevent C-Q to exit browser.

      "browser.feeds.showFirstRunUI" = false;
      "browser.newtabpage.enabled" = false; # Make new tabs blank
      "browser.download.useDownloadDir" = false;
      "browser.download.viewableInternally.typeWasRegistered.svg" = true;
      "browser.download.viewableInternally.typeWasRegistered.webp" = true;
      "browser.download.viewableInternally.typeWasRegistered.xml" = true;

      "browser.in-content.dark-mode" = true;

      "browser.link.open_newwindow" = false;

      "browser.search.region" = "NL";
      "browser.search.widget.inNavBar" = true;

      "browser.shell.checkDefaultBrowser" = false;
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

      "widget.use-xdg-desktop-portal.file-picker" = 1;

      "general.autoScroll" = true;
      "general.useragent.locale" = "en-US";

      "extensions.activeThemeID" = "{f5525f34-4102-4f6e-8478-3cf23cfeff7a}";

      # "extensions.extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";
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

      "devtools.theme" = "auto";

      # Silence some stuff
      "services.sync.prefs.sync.browser.safebrowsing.downloads.enabled" = false;
      "services.sync.prefs.sync.browser.safebrowsing.malware.enabled" = false;
      "services.sync.prefs.sync.browser.safebrowsing.phising.enabled" = false;
      "services.sync.prefs.sync.browser.safebrowsing.passwords.enabled" = false;

      # Disable password save prompts
      "signon.passwordEditCapture.enabled" = false;
      "layout.forms.reveal-password-context-menu.enabled" = false;
      "services.sync.engine.passwords" = false;
      "signon.rememberSignons" = false;
      "general.config.obscure_value" = 0;
    }
    // lib.optionalAttrs (config.networking.hostName == "terra") {
      # TODO use an option to inject this outside
      # Hardware video decoding support.
      "media.ffmpeg.vaapi.enabled" = true;
      "media.gpu-process-decoder" = true;
      "dom.webgpu.enabled" = true;
      "gfx.webrender.all" = true;
      "layers.mlgpu.enabled" = true;
      "layers.gpu-process.enabled" = true;
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

  extensions = with firefox-addons.packages.${pkgs.system}; [
    bitwarden
    darkreader
    ff2mpv
    # auto-accepts cookies, use only with privacy-badger & ublock-origin
    #ctrl-number-to-switch-tabs #TODO get this somehow?
    i-dont-care-about-cookies
    # link-cleaner
    privacy-badger
    to-deepl
    ublock-origin
    unpaywall
    vimium
    sponsorblock
  ];

  bookmarks = [
    {
      name = "monkeyType";
      tags = ["monkey"];
      keyword = "monkey";
      url = "https://monkeytype.com/?testSettings=NoIgxgrgzgLg9gWxAGnNeTkG8QwKYAeMIAXKDABZ4ohwBmN8NAhgHYAmLNAlqz1D2KoAnnAiMKzISCo0A7swGo6cAE404fVM1XVUc7pRZKQASRoVuJynmE0ARnpBSNrJ5IBuTylZp1ViBrqqJKcqPZ2qKxw0nJqYSD2ELGS0lCITnJOYGwayRo2wSBZuiwANmUSeKX6VFogEAAONNBOohBFFHByNFDM3Am5qHjMYBS9srXcYzTscFXcRTDcCE7cDPrcFfLMkc72YtIIbHs29TaYxaqGmWJlCWXcANZO6VVQ7tU0ZZoA5jTHF4SXj-VAfdwrRhxCyKb5wOBPAFqJzsXY0MB3BK-eaoDGrWYDGisCAIRxFdIQDhEnEgBBwWA0Rp4OCNMpOBB7OBeIpPaI9fRSL6oShDcDMbbKRYM2o0457OZyepQAZORx4ep8vy8QasPZufnFNSI1CNHTSGDMIGoX54aSs0bs5jsJyPLzyKg1Zx0fBFeyjY0gR4wGBs1xlPYBSkJY71YQjIo5fFgroGvDcvbYuDRpy-bhu1BiIpRoUgVjMJMgdMSSO-caoABW6D8akuH1Y+FYYBzuhcwssrADfT2VDKzVQPwNjzcBLodBLMA69RyrQBEBmqFWoscKk9dPzIGutekB0590Y8N65e8eAlIDmeBMH3NFF0mTY0n6RSyt-FbxNZTRMFjlvdUEkafIQgyGgewSSQqRNNRpAA1QbV6Jkf3YBI03Vb42Fg6p2SbcJuFBGQSLrEAoDXCiVAqboWDAFI9kUANViXODUP0dUkPI6Qnm1DRZyJPA8FgsQPkZaYF09GBVD2aAWF+fp6jYFZxUZOBeCOGIPXkNQzyieMHAgLYEg+MoNhAeMjGUKRdJCEYzIteDaEVRlmE4yiuggAzwDEds5ObKMWFYKASl6MZ4Uqa0AgNWAIHYPZYC2aLA3jep7XbdEuRLFQs16Skgt9W0shwsELXwGgXjwMcrLjYTuVw6U0ufMQj3RQxTlfdEAigEw6B0S5JFUJyzQBXjengQKwWYA0BvJEZZlUWbvjwb1cMq1BVEKqZQxNXQ+vRH4JKiCatpGVLHjnPw8ANaJVBs2gmSVETLngG1CmEoh3RudFLHuXR6kcXN6mxWJxQDQhy1ZJwRhOkBTSZIpfkjWrxQUYQTAQaBpgkelVR0gEdADegO1W4MS0pZZUoQLYnGuRrcR0G7bXRHRXjwDEXIOBE2dUabcHhQcwG4dUuxoEZpACQJlGuUCHDwJT6hVZgtSgCi6Sp5TJpZVxxfCRRPmZyDVHhyA0g6N8YHXPyfiKAb9cNfKN214ZoggWtGQA3gaFzVRUugCB1JEfzSJg5iDn3bCil0B4rFaj2aJE1KLTKAN7EWMz4SBrN5TgUiBtp8MCV0RiNPhtlmH3dJWFIzcqM9OY1EZAJ2DXY8ALAQcugeokSWqYPwAAw7NhcgBHCAH2WTQYUaZ7soQGHNq87g0Z7GELOguAu6CZ17cWV5DgoxoAnsNlLkaUXHfgXzeVu9yR8o3hr91mU9pAfja7Qh0LHjBJHGat5YqFMljbRRB0EEFgoyxy1PuXQqxSQllgDVCWOhi6QV8lkZqKN-IJC0gRZqPYbYDWatyewvRIHjnjmVJ+BBGDMDPt4ZaXhLoPixmoVglDcA0OVIvd+HxuSDw8N0G854FAjR2EUACzElK8GaqaEBSoJzom4iWH4+4kY1yRG4JK1R9zMDnkZLacAnRE1qstH2W0fI5hyqoDKPlUoYl8tEZYjthHTCcJSQwGlwrCm6PUOgvBsjVAtJYkAdB0HhPFKw0xuIBaolUKxUY-YnAuLfN4-8opAm-EtpNY2iQ4B0KiP5LUN4EgHWkBifmnMPyMI0sFVAcxpzhBGMkeUDNXjwGdn5dsrtwkBCysKEYNtSoBkCWWVKSl9woxEvUOAFEJ7TADM6Fhr9aBdlFOIy4-gRLjWJMvWAAzSJQCZCLQetNuZ4H7AkMAlclj9FSifLMa4nAOzSLJES0hn4ax8ssVkeodJcIxB0eGsBALFCoKI5QDjmyqEdmfSeGh7D1hqbMTmKoCqqAdiiEStU6Qz1QFYACLk8ppExvgS4SQoCnCntBTm8QHAmMqYgOkoM4C+UaPSZUdTMnNMovgWJd4BZxA4Go5gic8bQDwopGky12KcwDEpCs6sDGwwnoKCwMRxqP3sDWCg0gqC9kopqYUB8HDXC-iIB8BIwWDPCSlVB8jlJITYDkjyThyx-F9nK-+0SaBxnBvudgARaqGt7toC+B1uK-yrvKNgjt1QgycJy5U08VKqEuAYZ0l4thEx9NwQeyoABeTgPA6F0cGfhTJLTyDwGdEANo3DLVSh4vNPoOpwvfqaRYPBOxlASiiPMGKwTCAqAw9+c4yh2mqJIRoJhL47zBAlZ0S5-JpHVZ6HsWjxyJseroE+D5o3aHDZRCAyLUXnVzASqyTbfjDipi3OAfoeWJFEuanSJZFZh2HeAG8qVHCPGwn4ZajFuDXp3LSsEGSDw-1HgqHWnoqIIFWKAvpUA2QoP2jlOEfK2SkUINUEW8MFC3hyNbDWa75BWAolAJ4ewDg6ASPWOAewDDtiQUauQ1wKb1AML5ORsl+52peI0aQvxh4mBRooEwGIDTMfIcMdgnllS-HqB4Kw0HTTNXSOtaFQNDz6t9rCLidkSyssekXR417HD5PGdR2ejRhwsleROEstyP2Plkq6mxfLGyLwcAwvYdb2qoHU2OzyqxWbGK1eECAEZ+igvZfuVYqd3S2nsgjaANHsIZR0B5ZajQKI+AkcmP1DlfKSB7Y0h8YBriOGyrzZQPxm7DEMBlg6vzjJ2IsA6ma10maVO4h0PYXNlR70YMIJkuEDQZ2ZYoZljnGQvkNhQtkdrU6pT6C5dIubjG3gpUjKQuTJS1xLNqdAAsy39tefWwDCsjWEBFsvMs0khGiziuqeGRirJlHhos5euqETZBWxuAY7B378VvNuwMlp2QZDtVAHI78fgJTQha0iT6PiqH3GMUyk0LEhZ6TXd8RIpBgfqOwKS5Py3jTTmhES2ZKDdLUErdyMiOagevcGthR0xBmQ6CfKwThFlRf5ZobwvARuPFJA11KzoVMZXhFImLVkCBIxWEegpwYZYf1sDwAZFDa78NcWMgC5osjtiSp-XoRdshbvcOyphTp2Q3lzowa4tV6CBMdqXOtcD6IbiPhLAgowyWknZQSF0cNzSRhferQ4weuyifkAEA5DPzy+c0kqD2Npmq3JGPpkYAYAKJX9Yx6CQuAv-2UQWXbiRmsJHgNRb199cSa9pkU7h5YqOegxM1Y6x5Yq8e+0pEaNC8Dqs25ryK+Mbq3kCdICJAeolVcSGwAMTi2RlxmjjzQskI-VZFsBX23F35xBjGzUTfST6h9bWCGqeXl6U9nNMTrjTt5TS9nDZNqeL2lmzu6LPuONvBqltECsNKHmdqFH-suITurt0tqNMKATBpTjSCckDiwBgFAhfiEPHGoEFrOH-jeDUtcGAMHqcpUiGkiHvPUMQWxAatBvFCusynYiWKaA9ElE0P8oynyhYi2scEmo+uptmtoDMt4BQApEzJfKlriJVkUKiKdvbNtNBqQUVpYIupROypTmwQEF2I-M5stMvDkjzoZHoX0ALCqqoLVGxqRLVpLKksFhQAcF+IoBRH6FLKZgmLFDchwgvOwcmnAHgK2LJFwgBnLjVPLBuJLNBGeowGeq8p6pIXeOyshPjiMNst9ipoZn2GEiEa6l2sSqLhIfzCNpYGtNlD8LqLzhoRchLrDOxkUMcMxkoQ+NljoDbG2AkHGHRAaDkipD0S3FpGioKugdIPLiEgVNBpANUnaldFLEAT0ssMSKqD8BoWMGNCEEauZJtmuGYX4ScAVPYF5tvlZF4Hauwa4j5Pks6IWgYG9NUJcCyCmr9JsP1l5IERMJiEggeoKjoHKp5ImLVLwGccytrjnN1tVj6LUTQButIJwnyoJhodEJXjuiwn9PGjmJ4Z8bVIcraDbJQLFBMEEo+kjDACNuyiSPUHSFvtYr0MQScVxl6jFOCvutEedIsp6IDoKgev4ZeFOtSPDKyB0IPN5gmN7JcFzEsZroUsII2gVKPsMY9AesGFbr1oaGxHSYoNeukP2mmkTKpqLsqGUIzLgHBOnHKjbMcORgVC-p3g+KcgWhUHsNkiwP4P0LBB7K8NQuSPgFCneFYJAI-DuOImZCsFsPkjkj+oQOrmLK8FUh6nPO-AcInEhG+iaIYDbBiEascI-DkCVmvi5CGq8I8NYWEtzt3sMGcUCpoJTnqcoOnn4gfoLDIWvsqGQUBH+jQFdmyACvIWIHHmyc4PzHmI6Mgqhhof4Qjj3IOupsqNqZChbPYLao7ANMIgmJoG4CcSmmkM9Dcj3AkANGJiXkECRLwIWsNJ0mTlzoKrqo5OiShD-gYQFkUF7kgorPQbMGuAGAJiTi7IkqLs6GIRpOBGbtkOocst9uqEERGDVJEsGrwCTGANMQVHPIhPTpzBRC9sdjBqdpNOkUiHWQjHZN8NwIsg8PnACAXtIBPDEKLOtp8jRiOKlJuQGE8lJhfGeo8GQQALqEpQAADq8QAASnhIECQIJngHxQACoa4iUcBiUDS-aSWGgSIkAACMAArKaviCQAALRqXVbS43DqAkAgAAAEIAAAvsgIpR8DZb+MpYmo8OrAAPoAAsGlAADEkmOdSNONxUAA";
    }

    {
      name = "WhatsApp";
      tags = ["whatsapp"];
      keyword = "whatsapp";
      url = "https://web.whatsapp.com";
    }

    {
      name = "Gmail";
      tags = ["gmail"];
      keyword = "gmail";
      url = "https://mail.google.com";
    }

    {
      name = "Calendar";
      tags = ["calendar"];
      keyword = "calendar";
      url = "https://calendar.google.com";
    }

    {
      name = "Maps";
      tags = ["maps"];
      keyword = "maps";
      url = "https://maps.google.com";
    }
  ];

  search = {
    force = true;
    engines = {
      "Nix Packages" = {
        urls = [
          {
            template = "https://search.nixos.org/packages";
            params = [
              {
                name = "type";
                value = "packages";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];

        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@p"];
      };

      "Nix Options" = {
        urls = [
          {
            template = "https://search.nixos.org/options";
            params = [
              {
                name = "type";
                value = "options";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];

        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@o"];
      };

      "Home Manager Options" = {
        urls = [
          {
            template = "https://home-manager-options.extranix.com/";
            params = [
              {
                name = "query";
                value = "{searchTerms}";
              }
              {
                name = "releae";
                value = "master";
              }
            ];
          }
        ];

        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@h"];
      };

      "Github" = {
        urls = [
          {
            template = "https://github.com/search/";
            params = [
              {
                name = "q";
                value = "{searchTerms}";
              }
              {
                name = "type";
                value = "code";
              }
            ];
          }
        ];

        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@g"];
      };

      "Youtube" = {
        urls = [
          {
            template = "https://www.youtube.com/results";
            params = [
              {
                name = "search_query";
                value = "{searchTerms}";
              }
            ];
          }
        ];

        # icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@y"];
      };

      "Spotify" = {
        urls = [
          {
            template = "https://open.spotify.com/search/{searchTerms}";
          }
        ];

        iconUpdateURL = "https://storage.googleapis.com/pr-newsroom-wp/1/2023/05/Spotify_Primary_Logo_RGB_Green.png";
        definedAliases = ["@s"];
      };

      "Cargo" = {
            urls = [{template = "https://crates.io/crates/{searchTerms}";}];
            definedAliases = ["@c"];
          };

      "CPPReference" = {
        urls = [
          {
            template = "https://duckduckgo.com/";
            params = [
              {
                name = "sites";
                value = "cppreference.com";
              }
              {
                name = "q";
                value = "{searchTerms}";
              }
            ];
          }
        ];

        # icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@x"];
      };

      "Reddit" = {
        urls = [
          {
            template = "https://reddit.com/r/{searchTerms}";
          }
        ];

        # icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@r"];
      };
    };
  };
in {
  home-manager.users.${username} = {
    home.sessionVariables.BROWSER = "firefox";

    programs.firefox = {
      enable = true;

      package =
        if pkgs.stdenv.isLinux
        then pkgs.firefox
        else pkgs.firefox-bin;

      profiles = {
        default = {
          id = 0;
          name = "privacy-friendly";
          inherit bookmarks search settings userChrome extensions;
        };

        shit = {
          name = "trade-privacy-for-convenience";
          id = 1;
          inherit bookmarks search extensions;
        };
      };
    };

    xdg.mimeApps.defaultApplications = builtins.listToAttrs (map
      (mimeType: {
        name = mimeType;
        value = ["firefox.desktop"];
      })
      mimeTypes);
  };
}
