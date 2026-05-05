{
  inputs,
  username,
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.rbw pkgs.wl-clipboard pkgs.wtype pkgs.pinentry-curses];

  home-manager.users.${username} = {
    config,
    pkgs,
    inputs,
    osConfig,
    ...
  }: {
    imports = [inputs.walker.homeManagerModules.default];

    programs.walker = {
      enable = true;
      runAsService = true; # Note: this option isn't supported in the NixOS module only in the home-manager module

      # All options from the config.toml can be used here https://github.com/abenz1267/walker/blob/master/resources/config.toml
      config = {
        theme = "nixos";

        keep_open_modifier = "shift";

        placeholders."default" = {
          input = "Search";
          list = "No Results";
        };

        providers = {
          default = [
            "desktopapplications"
            "calc"
            "runner"
            "menus"
            "websearch"
            "bitwarden"
          ];
          prefixes = [
            {
              provider = "websearch";
              prefix = "@";
            }
            {
              provider = "bitwarden";
              prefix = "!";
            }
          ];
        };

        elephant = {
          providers = [
            "bluetooth"
            "bookmarks"
            "calc"
            "clipboard"
            "desktopapplications"
            "files"
            "menus"
            "providerlist"
            "runner"
            "snippets"
            "symbols"
            "unicode"
            "websearch"
            "bitwarden"
          ];
        };

        keybinds = {
          quick_activate = ["F1" "F2" "F3" "F4"];
          close = ["Escape"];
          next = ["ctrl n"];
          previous = ["ctrl p"];
          left = ["Left"];
          right = ["Right"];
          down = ["ctrl n"];
          up = ["ctrl p"];
          toggle_exact = ["ctrl e"];
          resume_last_query = ["ctrl r"];
          page_down = ["Page_Down"];
          page_up = ["Page_Up"];
          show_actions = ["alt j"];
        };

        providers.actions = {
          bitwarden = [
            {
              action = "copy_password";
              bind = "Return";
            }
            {
              action = "copy_username";
              bind = "ctrl u";
            }
            {
              action = "copy_totp";
              bind = "ctrl t";
            }
          ];

          desktopapplications = [
            {
              action = "start";
              bind = "Return";
            }
            {
              action = "pin";
              bind = "ctrl w";
              after = "AsyncReload";
            }
            {
              action = "unpin";
              bind = "ctrl w";
              after = "AsyncReload";
            }
            {
              action = "pinup";
              bind = "ctrl i";
              after = "AsyncReload";
            }
            {
              action = "pindown";
              bind = "ctrl m";
              after = "AsyncReload";
            }
          ];
          clipboard = [
            {
              action = "pin";
              bind = "ctrl w";
              after = "AsyncReload";
            }
            {
              action = "unpin";
              bind = "ctrl w";
              after = "AsyncReload";
            }
          ];
        };
      };

      themes."nixos".style = let
        c = osConfig.lib.stylix.colors.withHashtag;
      in ''
        @define-color window_bg_color ${c.base00};
        @define-color accent_bg_color ${c.base0D};
        @define-color theme_fg_color  ${c.base05};
        @define-color subtle_fg_color ${c.base03};

        * { all: unset; }

        .box-wrapper {
          background: @window_bg_color;
          border-radius: 12px;
          padding: 12px;
          box-shadow: 0 8px 24px rgba(0,0,0,0.4);
        }

        .input {
          background: transparent;
          color: @theme_fg_color;
          caret-color: @accent_bg_color;
          padding: 8px 4px;
          border-bottom: 1px solid alpha(@subtle_fg_color, 0.3);
        }

        .input placeholder { opacity: 0.4; color: @subtle_fg_color; }

        .list { color: @theme_fg_color; }

        .item-box {
          border-radius: 8px;
          padding: 8px 10px;
        }

        child:hover .item-box,
        child:selected .item-box {
          background: alpha(@accent_bg_color, 0.15);
        }

        .item-text { }
        .item-subtext { font-size: 11px; opacity: 0.45; }
        .item-image { margin-right: 8px; }
        .normal-icons { -gtk-icon-size: 16px; }
        .large-icons  { -gtk-icon-size: 28px; }

        .keybind-hints { opacity: 0.35; color: @subtle_fg_color; }
        scrollbar { opacity: 0; }

        .preview {
          border: 1px solid alpha(@accent_bg_color, 0.2);
          border-radius: 8px;
          padding: 8px;
          color: @theme_fg_color;
        }
      '';
    };
  };
}
