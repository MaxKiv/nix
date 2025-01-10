{
  config,
  pkgs,
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [bashInteractive];

    programs.bash = {
      enable = true;

      bashrcExtra = ''
        # Dotfiles management
        alias dot='${pkgs.git}/bin/git --git-dir=${config.home.homeDirectory}/git/nix/dotfiles/.git --work-tree=${config.home.homeDirectory}/git/nix/dotfiles'
        alias ds='dot status'
      '';

      # profileExtra = ''
      #   if [ -x "$(command -v tmux)" ] && [ -n "''${DISPLAY}" ] && [ -z "''${TMUX}" ]; then
      #       exec tmux new-session -d -s ''${USER} >/dev/null 2>&1
      #   fi
      # '';

      shellAliases = {
        open = "${pkgs.xdg-utils}/bin/xdg-open";
        # navigation shortcuts
        ".." = "cd ..";
        "..." = "cd ../../";
        "...." = "cd ../../../";
        "....." = "cd ../../../../";

        # ls
        ls = "${pkgs.eza}/bin/eza";
        ll = "${pkgs.eza}/bin/eza -la";
        lr = "${pkgs.eza}/bin/eza -la -snew";
        # ls="ls --color=auto";
        # ll="ls -alF";
        # la="ls -A";
        # l="ls -CF";

        grep = "grep --color=auto";

        fj = "fg";
        dn = "fg";
        n = "nvim";
        nv = "nvim";

        # git stuff
        gs = "${pkgs.git}/bin/git status";
        gba = "${pkgs.git}/bin/git branch -a";
        gd = "${pkgs.git}/bin/git diff";
        gds = "${pkgs.git}/bin/git diff --staged";
        gc = "${pkgs.git}/bin/git commit";
        gcs = "${pkgs.git}/bin/git commit --gpg-sign=\"Max Kivits\"";
        gf = "${pkgs.git}/bin/git fetch -p -t";
        gl = "${pkgs.git}/bin/git log --oneline --decorate --graph";
        glu = "${pkgs.git}/bin/git log --oneline --decorate --graph \"@{u}\"";
        glp = "${pkgs.git}/bin/git log -p";
        gp = "${pkgs.git}/bin/git push";
        gpf = "${pkgs.git}/bin/git push --force-with-lease";
        gau = "${pkgs.git}/bin/git add -u";
        gaa = "${pkgs.git}/bin/git add .";
        gcam = "${pkgs.git}/bin/git commit --amend --no-edit";
        gcams = "${pkgs.git}/bin/git commit --amend --no-edit --gpg-sign=\"Max Kivits\"";
        grc = "${pkgs.git}/bin/git rebase --continue";
        gr = "${pkgs.git}/bin/git rebase";
        gri = "${pkgs.git}/bin/git rebase -i";
        grs = "${pkgs.git}/bin/git rebase --gpg-sign=\"Max Kivits\"";
        gris = "${pkgs.git}/bin/git rebase -i --gpg-sign=\"Max Kivits\"";
        gru = "${pkgs.git}/bin/git reset \"@{u}\"";
        g- = "${pkgs.git}/bin/git switch -";

        # Tmux
        tms = "${pkgs.tmux}/bin/tmux new-session -s";
        tml = "${pkgs.tmux}/bin/tmux list-session";
        tma = "${pkgs.tmux}/bin/tmux a -t ";

        # Zellij
        zml = "${pkgs.zellij}/bin/zellij list-sessions";
        zma = "${pkgs.zellij}/bin/zellij attach";
        zms = "${pkgs.zellij}/bin/zellij -s";

        # xclip
        # clip = "${pkgs.xclip}/bin/xclip -sel clip";
      };
    };

    # Escape "$" in bash scripts using "''$"
    programs.bash.initExtra = ''
      # This command let's me execute arbitrary binaries downloaded through channels such as mason.
      export NIX_LD=$(nix eval --impure --raw --expr 'let pkgs = import <nixpkgs> {}; NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"; in NIX_LD')

      export BASH_ENV="~/.bash_aliases"

      function clip() {
        if [ -z "''${WAYLAND_DISPLAY}" ]; then
          ${pkgs.xclip}/bin/xclip -sel clip
        else
          ${pkgs.wl-clipboard-rs}/bin/wl-copy
        fi
      }

      mkcd() {
        mkdir "$1" && cd "$_"
      }

      # checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
      gsw() {
        local branches branch
        branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
        branch=$(echo "$branches" |
                 fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
        git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
      }

      # TODO make this work for all hosts and display servers
      # turn on/off x11 keyboard
      strd() {
        xinput set-int-prop 17 "Device Enabled" 8 0
      }
      drts() {
        xinput set-int-prop 17 "Device Enabled" 8 1
      }

      # global pushd/popd
      function gpushd() {
        filename="$HOME/.gstack.dirs"
        newdir=$(readlink -f "$1")
        if [ "$newdir" != "" ]; then
          echo $newdir >> $filename
        else
          newdir=$(readlink -f ".")
          echo $newdir >> $filename
        fi
      }
      function gpopd() {
        filename="$HOME/.gstack.dirs"
        dir=$(tail -n 1 $filename)
        sed -i '$ d' $filename
        if [ "$dir" != "" ]; then
          cd "$dir"
        fi
      }

      # TODO make sure dep packages are there
      # Tired of 9000+ zip formats, stolen from asinghani dotfiles
      extract () {
          if [[ -f $1 ]] ; then
              case $1 in
                  *.tar.bz2)   tar xjf $1     ;;
                  *.tar.gz)    tar xzf $1     ;;
                  *.bz2)       bunzip2 $1     ;;
                  *.rar)       unrar e $1     ;;
                  *.gz)        gunzip $1      ;;
                  *.tar)       tar xf $1      ;;
                  *.tbz2)      tar xjf $1     ;;
                  *.tgz)       tar xzf $1     ;;
                  *.zip)       unzip $1       ;;
                  *.Z)         uncompress $1  ;;
                  *.7z)        7z x $1        ;;
                  *)     echo "'$1' cannot be extracted" ;;
              esac
          else
              echo "'$1' is not a valid file"
          fi
      }

      # open a file selected by fzf in vim
      vf() {
        nvim "$(fzf-tmux)"
      }

      # fd - cd to selected directory
      fd() {
        local dir
        dir=$(find ''${1:-.} -path '*/\.*' -prune \
          -o -type d -print 2> /dev/null | fzf-tmux +m) &&
          cd "$dir"
        }

      # fda - including hidden directories
      fda() {
        local dir
        dir=$(find ''${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
      }

      # fopen - open file selected by fzf
      fopen() {
        xdg-open "$(fzf)"
      }

      # fkill - kill processes - list only the ones you can kill. Modified the earlier script.
      fkill() {
        local pid
        if [ "$UID" != "0" ]; then
          pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
        else
          pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
        fi
        if [ "x$pid" != "x" ]
        then
          echo $pid | xargs kill -''${1:-9}
        fi
      }

      ### Tmux ###
      tmf() {
        local session=$(tmux ls | cut -d":" -f1 | fzf)
        tmux a -t "$session"
      }
      tmd() {
        local session=$(tmux ls | cut -d":" -f1 | fzf)
        tmux kill-session -t "$session"
      }

      lsb() {
        local selected_file
        selected_file=$(find . -type f -executable 2>/dev/null | fzf-tmux)

        if [ -n "$selected_file" ]; then
          echo -n "$selected_file" | xclip -selection clipboard
          echo "Copied to clipboard: $selected_file"
        else
          echo "No file selected."
        fi
      }

      ### Zellij ###
      # Fuzzy create / attach session
      zmf() {
        layout_dir="${config.home.homeDirectory}/git/nix/dotfiles/.config/zellij/layouts"

        # Strip ANSI color codes from zellij output
        zellij_sessions=$(zellij list-sessions | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $1}')
        layouts=$(ls "$layout_dir" | sed 's/\.kdl$//') # Strip .kdl extensions

        # Combine sessions and layouts, remove duplicates, and pass to fzf
        selected_session=$(
          (echo "$zellij_sessions" && echo "$layouts") | sort -u | fzf
        )

        if [ -n "$selected_session" ]; then
          # Check if the selection is an existing session
          if echo "$zellij_sessions" | grep -q "^$selected_session$"; then
            # Attach to the existing session
            zellij attach "$selected_session"
          elif [ -f "$layout_dir/$selected_session.kdl" ]; then
            # Create a new session using the layout
            zellij -n $selected_session -s $selected_session
          else
            echo "Error: Selected item is neither an existing session nor a layout."
          fi
        fi
      }
      # Fuzzy delete session
      zmd() {
        zellij_sessions=$(zellij list-sessions | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $1}')
        selected_session=$(
          (echo "$zellij_sessions") | sort -u | fzf
        )
        if [ -n "$selected_session" ]; then
          zellij delete-session "$selected_session" --force
        fi
      }
    '';
  };
}
