{ username, ... }:
{
  services.mpd.user = username;
  systemd.services.mpd.environment = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    XDG_RUNTIME_DIR = "/run/user/1000"; # User-id 1000 must match above user. MPD will look inside this directory for the PipeWire socket.
  };

  home-manager.users.${username} =
    { config
    , pkgs
    , ...
    }: {
      # Media player daemon
      services.mpd = {
        enable = true;
        musicDirectory = "${config.xdg.userDirs.music}";
        network.startWhenNeeded = true;
        dataDir = "${config.home.homeDirectory}/.config/mpd";
        extraConfig = ''
          follow_outside_symlinks "yes"
          auto_update "yes"
          audio_output {
            type "fifo"
            name "Visualizer"
            format "44100:16:2"
            path "/tmp/mpd.fifo"
          }
          audio_output {
            type "pipewire"
            name "My PipeWire Output"
          }
        '';
      };

      # MPD Client
      programs.ncmpcpp = {
        enable = true;
        package = pkgs.ncmpcpp.override {
          visualizerSupport = true;
          clockSupport = true;
          taglibSupport = true;
        };
        mpdMusicDir = "${config.xdg.userDirs.music}";
        settings = {
          # Miscelaneous
          startup_screen = "visualizer";
          ncmpcpp_directory = "${config.home.homeDirectory}/.config/ncmpcpp";
          ignore_leading_the = false;
          external_editor = "nvim";
          message_delay_time = 1;
          playlist_disable_highlight_delay = 2;
          autocenter_mode = "yes";
          centered_cursor = "yes";
          allow_for_physical_item_deletion = "yes";
          lines_scrolled = "0";
          follow_now_playing_lyrics = "yes";
          lyrics_fetchers = "musixmatch";

          # visualizer
          visualizer_data_source = "/tmp/mpd.fifo";
          visualizer_output_name = "mpd_visualizer";
          visualizer_type = "ellipse";
          visualizer_look = "●●";
          visualizer_color = "blue, green";

          # appearance
          colors_enabled = "yes";
          playlist_display_mode = "classic";
          user_interface = "classic";
          volume_color = "white";

          # window
          song_window_title_format = "Music";
          statusbar_visibility = "yes";
          header_visibility = "no";
          titles_visibility = "no";
          # progress bar
          progressbar_look = "━━━";
          progressbar_color = "black";
          progressbar_elapsed_color = "blue";

          # song list
          song_status_format = "$7%t";
          song_list_format = "$(008)%t$R  $(247)%a$R$5  %l$8";
          song_columns_list_format = "(53)[blue]{tr} (45)[blue]{a}";

          current_item_prefix = "$b$2| ";
          current_item_suffix = "$/b$5";

          now_playing_prefix = "$b$5| ";
          now_playing_suffix = "$/b$5";

          song_library_format = "{{%a - %t} (%b)}|{%f}";

          # colors
          main_window_color = "blue";

          current_item_inactive_column_prefix = "$b$5";
          current_item_inactive_column_suffix = "$/b$5";

          color1 = "white";
          color2 = "blue";
        };
      };
    };
}
