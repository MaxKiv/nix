{
  pkgs,
  lib,
  config,
  username,
  inputs,
  ...
}: {
  imports = [
    ../components/waybar
    # ../components/mako
    # ../components/wofi
    ../components/clipman
    # ../components/flashfocus
    # ../components/satty
    ../components/swappy
    # ../components/kanshi
    # TODO: fix this
    # ../components/xdg-desktop-portal-termfilechooser
    ../components/sddm
    ../components/xdg-portals
    ../components/playerctld
  ];

  my.sddm.autoLoginSession = "niri";

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    imports = with inputs.niri.homeModules; [
      niri
      stylix
    ];

    stylix.targets.niri.enable = false;

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    # xdg.configFile = {
    #   "niri/config.kdl" = {
    #     source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/niri/config.kdl";
    #   };
    # };
  };
}
# {
#   inputs,
#   inputs',
#   pkgs,
#   lib,
#   config,
#   ...
# }: let
#   screenshotActiveMonitor = lib.getExe (
#     pkgs.writeShellApplication {
#       name = "screenshot-active-monitor.sh";
#       runtimeInputs = with pkgs; [
#         satty
#         grim
#         jq
#         wl-clipboard
#         libnotify
#         config.programs.niri.package
#       ];
#       text = ''
#         grim -o "$(niri -j monitors all | \
#           niri msg -j focused-output | jq -r '.name')" - | \
#             if [ ! -v "$1" ]; then
#               case "$1" in
#                 "--edit")
#                   satty --filename - --fullscreen --early-exit --copy-command 'wl-copy' --initial-tool 'crop'
#                   ;;
#                 *)
#                   wl-copy && notify-send 'Screenshot: copied to clipboard.'
#                   ;;
#               esac
#             else
#               wl-copy && notify-send 'Screenshot: copied to clipboard.'
#             fi
#       '';
#     }
#   );
# in {
#   programs.niri = {
#     enable = true;
#     package = inputs'.niri.packages.niri-unstable;
#     settings = {
#       screenshot-path = null;
#       prefer-no-csd = true;
#       outputs =
#         {
#           atrebois = {
#             "HDMI-A-1" = {
#               mode = {
#                 width = 2560;
#                 height = 1080;
#                 refresh = 75.0;
#               };
#               scale = 1;
#               position = {
#                 x = 0;
#                 y = 0;
#               };
#             };
#             "DP-1" = {
#               mode = {
#                 width = 1920;
#                 height = 1080;
#                 refresh = 239.964;
#               };
#               variable-refresh-rate = true;
#               scale = 1;
#               position = {
#                 x = 2560;
#                 y = 0;
#               };
#             };
#           };
#           rocaille = {
#             "eDP-1" = {
#               mode = {
#                 width = 2160;
#                 height = 1440;
#                 refresh = 60.0;
#               };
#               scale = 1.5;
#               position = {
#                 x = 0;
#                 y = 0;
#               };
#             };
#           };
#         }
#         .${
#           config.home.sessionVariables.HOSTNAME
#         };
#       input = {
#         warp-mouse-to-focus = true;
#         focus-follows-mouse = {
#           enable = true;
#           max-scroll-amount = "0%";
#         };
#         keyboard = {
#           repeat-rate = 50;
#           repeat-delay = 300;
#           xkb = {
#             layout = "us";
#             variant = "intl";
#             options =
#               {
#                 atrebois = null;
#                 rocaille = "ctrl:swapcaps";
#               }
#               .${
#                 config.home.sessionVariables.HOSTNAME
#               };
#           };
#         };
#         mouse = {
#           accel-speed = 0.0;
#           accel-profile = "flat";
#         };
#         touchpad = {
#           click-method = "clickfinger";
#           accel-speed = 0.0;
#           accel-profile = "flat";
#           tap = true;
#           natural-scroll = true;
#           dwt = false;
#         };
#       };
#       hotkey-overlay.skip-at-startup = true;
#       environment = {
#         DISPLAY = ":0";
#       };
#       spawn-at-startup = [
#         {
#           command = [
#             "${lib.getExe' inputs'.niri.packages.xwayland-satellite-unstable "xwayland-satellite"}"
#           ];
#         }
#         {
#           command = [
#             "${lib.getExe pkgs.xorg.xrandr}"
#             "--output"
#             "${
#               {
#                 atrebois = "DP-1";
#                 rocaille = "eDP-1";
#               }
#               .${
#                 config.home.sessionVariables.HOSTNAME
#               }
#             }"
#             "--primary"
#           ];
#         }
#       ];
#       overview = {
#         backdrop-color = config.lib.stylix.colors.withHashtag.base00;
#         zoom = 0.80;
#       };
#       binds = with config.lib.niri.actions; {
#         "Mod+Return".action.spawn = [
#           "${lib.getExe config.programs.kitty.package}"
#           "-1"
#         ];
#         "Mod+Space".action.spawn = ["${lib.getExe config.programs.anyrun.package}"];
#         "Mod+E".action.spawn = ["${lib.getExe pkgs.nautilus}"];
#         # "Mod+Alt+F".action = pin-active; # FIXME: https://github.com/YaLTeR/niri/issues/932
#         "XF86AudioRaiseVolume" = {
#           allow-when-locked = true;
#           action.spawn = [
#             "wpctl"
#             "set-volume"
#             "@DEFAULT_AUDIO_SINK@"
#             "1%+"
#           ];
#         };
#         "XF86AudioLowerVolume" = {
#           allow-when-locked = true;
#           action.spawn = [
#             "wpctl"
#             "set-volume"
#             "@DEFAULT_AUDIO_SINK@"
#             "1%-"
#           ];
#         };
#         "XF86AudioMute" = {
#           allow-when-locked = true;
#           action.spawn = [
#             "wpctl"
#             "set-mute"
#             "@DEFAULT_AUDIO_SINK@"
#             "toggle"
#           ];
#         };
#         "XF86AudioMicMute" = {
#           allow-when-locked = true;
#           action.spawn = [
#             "wpctl"
#             "set-mute"
#             "@DEFAULT_AUDIO_SOURCE@"
#             "toggle"
#           ];
#         };
#         "XF86MonBrightnessUp" = {
#           allow-when-locked = true;
#           action.spawn = [
#             "brightnessctl"
#             "set"
#             "5%+"
#           ];
#         };
#         "XF86MonBrightnessDown" = {
#           allow-when-locked = true;
#           action.spawn = [
#             "brightnessctl"
#             "set"
#             "5%-"
#           ];
#         };
#         "Mod+Alt+S".action.spawn = [
#           "${lib.getExe' pkgs.systemd "systemctl"}"
#           "suspend"
#         ];
#         "Mod+Alt+Q".action = quit;
#         "Mod+Shift+Q".action.spawn = [
#           "${lib.getExe' pkgs.systemd "loginctl"}"
#           "lock-session"
#         ];
#         "Mod+W".action = close-window;
#         "Mod+F".action = maximize-column;
#         "Mod+Ctrl+F".action = expand-column-to-available-width;
#         "Mod+Shift+F".action = fullscreen-window;
#         "Mod+Tab" = {
#           action = toggle-overview;
#           repeat = false;
#         };
#         "Mod+C".action = center-column;
#         "Mod+Ctrl+C".action = center-visible-columns;
#         "Mod+V".action = toggle-window-floating;
#         "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
#         "Mod+G".action = toggle-column-tabbed-display;
#         "Mod+Shift+Period".action = move-column-to-monitor-right;
#         "Mod+Shift+Comma".action = move-column-to-monitor-left;
#         "Mod+Period".action = focus-monitor-right;
#         "Mod+Comma".action = focus-monitor-left;
#         "Mod+Ctrl+Period".action = focus-monitor-down;
#         "Mod+Ctrl+Comma".action = focus-monitor-up;
#         "Mod+H".action = focus-column-left;
#         "Mod+J".action = focus-window-down;
#         "Mod+K".action = focus-window-up;
#         "Mod+L".action = focus-column-right;
#         "Mod+Shift+H".action = move-column-left;
#         "Mod+Shift+J".action = move-window-down;
#         "Mod+Shift+K".action = move-window-up;
#         "Mod+Shift+L".action = move-column-right;
#         "Mod+Ctrl+H".action = focus-monitor-left;
#         "Mod+Ctrl+J".action = focus-workspace-down;
#         "Mod+Ctrl+K".action = focus-workspace-up;
#         "Mod+Ctrl+L".action = focus-monitor-right;
#         "Mod+Ctrl+B".action = consume-or-expel-window-left;
#         "Mod+Ctrl+N".action = consume-or-expel-window-right;
#         "Mod+Page_Down".action = focus-workspace-down;
#         "Mod+Page_Up".action = focus-workspace-up;
#         "Mod+Shift+Page_Down".action = move-column-to-workspace-down;
#         "Mod+Shift+Page_Up".action = move-column-to-workspace-up;
#         "Mod+WheelScrollUp" = {
#           cooldown-ms = 150;
#           action = focus-workspace-up;
#         };
#         "Mod+WheelScrollDown" = {
#           cooldown-ms = 150;
#           action = focus-workspace-down;
#         };
#         "Mod+Shift+WheelScrollUp" = {
#           action = focus-column-left;
#         };
#         "Mod+Shift+WheelScrollDown" = {
#           action = focus-column-right;
#         };
#         "Mod+WheelScrollLeft" = {
#           cooldown-ms = 150;
#           action = focus-column-left;
#         };
#         "Mod+WheelScrollRight" = {
#           cooldown-ms = 150;
#           action = focus-column-right;
#         };
#         "Mod+1".action.focus-workspace = 1;
#         "Mod+2".action.focus-workspace = 2;
#         "Mod+3".action.focus-workspace = 3;
#         "Mod+4".action.focus-workspace = 4;
#         "Mod+5".action.focus-workspace = 5;
#         "Mod+6".action.focus-workspace = 6;
#         "Mod+7".action.focus-workspace = 7;
#         "Mod+8".action.focus-workspace = 8;
#         "Mod+9".action.focus-workspace = 9;
#         "Mod+0".action.focus-workspace = "tmp";
#         "Mod+Ctrl+1".action.move-column-to-workspace = 1;
#         "Mod+Ctrl+2".action.move-column-to-workspace = 2;
#         "Mod+Ctrl+3".action.move-column-to-workspace = 3;
#         "Mod+Ctrl+4".action.move-column-to-workspace = 4;
#         "Mod+Ctrl+5".action.move-column-to-workspace = 5;
#         "Mod+Ctrl+6".action.move-column-to-workspace = 6;
#         "Mod+Ctrl+7".action.move-column-to-workspace = 7;
#         "Mod+Ctrl+8".action.move-column-to-workspace = 8;
#         "Mod+Ctrl+9".action.move-column-to-workspace = 9;
#         "Mod+Ctrl+0".action.move-column-to-workspace = "tmp";
#         "Mod+Alt+H".action = move-workspace-to-monitor-left;
#         "Mod+Alt+J".action = move-workspace-down;
#         "Mod+Alt+K".action = move-workspace-up;
#         "Mod+Alt+L".action = move-workspace-to-monitor-right;
#         "Mod+B".action = set-column-width "+5%";
#         "Mod+Shift+B".action = set-column-width "-5%";
#         "Mod+N".action = set-window-height "+5%";
#         "Mod+Shift+N".action = set-window-height "-5%";
#         "Ctrl+Print".action = screenshot-window;
#         "Print".action.spawn = [
#           "${screenshotActiveMonitor}"
#           "--edit"
#         ];
#         "Mod+Shift+S".action.spawn = [
#           "${screenshotActiveMonitor}"
#           "--edit"
#         ];
#       };
#       layout = {
#         gaps = 8;
#         default-column-width.proportion = 0.7;
#         focus-ring.width = 4;
#         border.width = 2;
#         shadow = {
#           enable = true;
#           softness = 10;
#           spread = 3;
#           offset = {
#             x = 7;
#             y = 7;
#           };
#         };
#       };
#       animations = {
#         enable = true;
#         slowdown = 1.0;
#       };
#       workspaces =
#         {
#           atrebois = {
#             "1-main" = {
#               name = "main";
#               open-on-output = "DP-1";
#             };
#             "2-browser" = {
#               name = "browser";
#               open-on-output = "HDMI-A-1";
#             };
#             "3-discord" = {
#               name = "discord";
#               open-on-output = "HDMI-A-1";
#             };
#             "4-gaming" = {
#               name = "gaming";
#               open-on-output = "DP-1";
#             };
#             "5-other" = {
#               name = "other";
#               open-on-output = "HDMI-A-1";
#             };
#             "6-tmp" = {
#               name = "tmp";
#               open-on-output = "DP-1";
#             };
#           };
#           rocaille = {
#             "1-main".name = "main";
#             "2-browser".name = "browser";
#             "3-discord".name = "discord";
#             "4-gaming".name = "gaming";
#             "5-other".name = "other";
#             "6-tmp".name = "tmp";
#           };
#         }
#         .${
#           config.home.sessionVariables.HOSTNAME
#         };
#       window-rules = [
#         {
#           matches = [
#             {
#               app-id = "^zen$";
#               at-startup = true;
#             }
#           ];
#           open-maximized = true;
#           open-on-workspace = "browser";
#         }
#         {
#           matches = [
#             {
#               app-id = "^vesktop$";
#               at-startup = true;
#             }
#           ];
#           default-column-width.proportion = 0.5;
#           open-on-workspace = "discord";
#         }
#         {
#           matches = [
#             {
#               app-id = "^thunderbird$";
#               at-startup = true;
#             }
#           ];
#           default-column-width.proportion = 0.5;
#           open-on-workspace = "other";
#         }
#         {
#           matches = [
#             {
#               app-id = "^steam$";
#               title = "^Steam$";
#             }
#           ];
#           default-column-width.proportion = 0.8;
#           open-on-workspace = "gaming";
#         }
#         {
#           matches = [
#             {
#               app-id = "^steam$";
#               title = "^Friends List$";
#             }
#           ];
#           default-column-width.proportion = 0.2;
#           open-on-workspace = "gaming";
#         }
#       ];
#     };
#   };
#
#   systemd.user.services = {
#     hypridle.Unit.After = lib.mkForce "graphical-session.target";
#     hyprpaper.Unit.After = lib.mkForce "graphical-session.target";
#   };
#
#   programs.hyprlock = {
#     enable = true;
#     settings = {
#       general = {
#         disable_loading_bar = false;
#         hide_cursor = false;
#         grace = 5;
#         ignore_empty_input = true;
#         immediate_render = true;
#         text_trim = true;
#       };
#       auth = {
#         pam = {
#           enabled = true;
#           module = "hyprlock";
#         };
#         fingerprint = {
#           enabled = true;
#           ready_message = "Scan fingerprint to unlock.";
#           present_message = "Scanning fingerprint...";
#         };
#       };
#       background = {
#         blur_passes = 3;
#         blur_size = 8;
#       };
#       image = {
#         path = builtins.toString (
#           pkgs.fetchurl {
#             url = "https://avatars.githubusercontent.com/u/70974710?v=4";
#             hash = "sha256-HAQYSeKEk3pjleDruExUzvqyXJGBI6t6+BZDQ/ex5B8=";
#           }
#         );
#         size = 150;
#         rounding = -1; # -1 = circle
#         border_size = 1;
#         position = "0, 130";
#         halign = "center";
#         valign = "center";
#       };
#       label = {
#         text =
#           lib.strings.toUpper (builtins.head (lib.strings.stringToCharacters config.home.username))
#           + lib.strings.concatStrings (builtins.tail (lib.strings.stringToCharacters config.home.username)); # Uppercase firt letter
#         font_size = 24;
#         font_family = "Lexend";
#         position = "0, 30";
#         halign = "center";
#         valign = "center";
#       };
#       input-field = {
#         size = "300, 40";
#         dots_center = true;
#         fade_on_empty = false;
#         outline_thickness = 2;
#         shadow_passes = 2;
#         placeholder_text = "Password...";
#         position = "0, -30";
#         halign = "center";
#         valign = "center";
#       };
#     };
#   };
#
#   services.hypridle = {
#     enable = true;
#     settings = {
#       general = {
#         ignore_dbus_inhibit = false;
#         ignore_systemd_inhibit = false;
#         lock_cmd = "${lib.getExe' pkgs.procps "pidof"} hyprlock || ${lib.getExe pkgs.hyprlock} || cw";
#         before_sleep_cmd = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
#         after_sleep_cmd = "${lib.getExe pkgs.niri} msg action power-on-monitors";
#       };
#       listener = [
#         {
#           timeout = 20 * 60;
#           on-timeout = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
#         }
#         {
#           timeout = 25 * 60;
#           on-timeout = "${lib.getExe pkgs.niri} msg action power-off-monitors";
#           on-resume = "${lib.getExe pkgs.niri} msg action power-on-monitors";
#         }
#         # {
#         #   timeout = 45 * 60;
#         #   on-timeout = "systemctl suspend";
#         # }
#       ];
#     };
#   };
#
#   xdg = {
#     enable = true;
#     userDirs = {
#       enable = true;
#       createDirectories = true;
#       desktop = null;
#       documents = "${config.home.homeDirectory}/Documents";
#       download = "${config.home.homeDirectory}/Downloads";
#       music = null;
#       pictures = "${config.home.homeDirectory}/Pictures";
#       publicShare = null;
#       templates = null;
#       videos = null;
#     };
#     portal = {
#       enable = true;
#       xdgOpenUsePortal = true;
#       extraPortals = with pkgs; [xdg-desktop-portal-gnome];
#       config.common.default = ["gnome"];
#     };
#     autostart = {
#       enable = true;
#       entries = map (p: "${p}/share/applications/${p.meta.mainProgram}.desktop") [
#         inputs'.zen-browser-flake.packages.zen-browser
#         pkgs.thunderbird
#         config.programs.vesktop.package
#       ];
#     };
#   };
# }

