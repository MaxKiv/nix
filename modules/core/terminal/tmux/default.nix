{ config, pkgs, home-manager, username, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  home-manager.users.${username} = {
    home.packages = with pkgs; [ tmux ];

    programs.tmux = {
      enable = true;
      clock24 = true; # use 24 hour clock

      prefix = "C-Space";
      baseIndex = 1;

      mouse = true; # enable mouse support
      terminal = "screen-256color";
      disableConfirmationPrompt = true; # kill panes instantly
      keyMode = "vi";

      newSession = true; # spawn new session when attaching to non-existing

      extraConfig = ''
        setw -g automatic-rename on   	# rename window to reflect current program
        set -g renumber-windows on    	# renumber windows when a window is closed

        set -g default-terminal "screen-256color"
        set -ag terminal-overrides ",alacritty:RGB,xterm-256color:RGB"

        set -g display-panes-time 800 # slightly longer pane indicators display time
        set -g display-time 1000      # slightly longer status messages display time
        set -g set-titles on          # set terminal title
        set-option -g repeat-time 200 # lower the prefix key repeat time

        # Terminal title bar
        set -g set-titles-string "#I:#P - #W - #T"

        # Status bar looks
        set -g status "on"
        set -g status-justify "left"
        set -g status-left-style "none"
        set -g status-right-style "none"
        set -g status-right-length "100"
        set -g status-left-length "100"
        setw -g window-status-separator ""
        set -g default-terminal "screen-256color"
        set -ag terminal-overrides ",alacritty:RGB,xterm-256color:RGB"

        bind r source-file ~/.tmux.conf \; display-message "Configuration Reloaded"
        bind-key j command-prompt -p "join pane from window:"  "join-pane -s '%%'"
        bind-key s command-prompt -p "send pane to window:"  "join-pane -t '%%'"
        bind Enter copy-mode
        bind C-Enter copy-mode
        bind -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind P paste-buffer
        unbind '"'
        unbind %
        bind - split-window -v -c "#{pane_current_path}"
        bind | split-window -h -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
        bind -r C-L swap-window -t +1\; select-window -t +1
        bind -r C-H swap-window -t -1\; select-window -t -1
        bind -r h select-pane -L  # move left
        bind -r j select-pane -D  # move down
        bind -r k select-pane -U  # move up
        bind -r l select-pane -R  # move right
        #bind o swap-pane -D       # swap current pane with the next one
        #bind i swap-pane -U       # swap current pane with the previous one
        bind-key -r > swap-pane -t '{right-of}'
        bind-key -r < swap-pane -t '{left-of}'
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5
        bind -r C-Up resize-pane -U 5
        bind -r C-Down resize-pane -D 5
        bind -r C-Left resize-pane -L 5
        bind -r C-Right resize-pane -R 5
        bind-key x kill-pane
        bind-key X kill-window
        bind-key C-x kill-session
      '';

      plugins = with pkgs; [
        { plugin = tmuxPlugins.cpu; }
        { plugin = tmuxPlugins.yank; }
        { plugin = tmuxPlugins.open; }
        { plugin = tmuxPlugins.sensible; }
        {
          plugin = tmuxPlugins.copycat;
          extraConfig = ''
            set -g @yank_selection 'primary' # or 'secondary' or 'clipboard'
          '';
        }
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavour 'mocha' # or frappe, macchiato, mocha
          '';
        }
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-save 'C-s'
            set -g @resurrect-restore 'C-r'
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5' # minutes    
          '';
        }
      ];

      #shell = "${pkgs.bash}/bin/bash";

    };

    #home.file = {
    #".tmux.conf" = { source = mkOutOfStoreSymlink ../../dotfiles/.tmux.conf; };
    # ".tmux.conf" = { source = "${dotfiles}/.tmux.conf"; };
    #};

  };

}
