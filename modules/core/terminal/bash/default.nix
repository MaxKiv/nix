{ config, pkgs, home-manager, username, ... }:

{

  home-manager.users.${username} = { config, pkgs, ... }:
    {
      home.packages = with pkgs; [ bashInteractive ];

      programs.bash = {
        enable = true;

        bashrcExtra = ''
          # Dotfiles management
          alias dot='${pkgs.git}/bin/git --git-dir=${config.home.homeDirectory}/git/nix/dotfiles/.git --work-tree=${config.home.homeDirectory}/git/nix/dotfiles'
          alias ds='dot status'
          alias df='dot fetch'
          alias dau='dot add -u'
          alias dcam='dot commit --amend --no-edit'
        '';

        # profileExtra = ''
        #   if [ -x "$(command -v tmux)" ] && [ -n "''${DISPLAY}" ] && [ -z "''${TMUX}" ]; then
        #       exec tmux new-session -d -s ''${USER} >/dev/null 2>&1
        #   fi
        # '';

        shellAliases = {

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
          vim = "nvim";

          # git stuff
          gs = "${pkgs.git}/bin/git status";
          gd = "${pkgs.git}/bin/git diff";
          gc = "${pkgs.git}/bin/git commit";
          gf = "${pkgs.git}/bin/git fetch -p -t";
          gl = "${pkgs.git}/bin/git log --oneline --decorate --graph";
          glu = "${pkgs.git}/bin/git log --oneline --decorate --graph \"@{u}\"";
          glp = "${pkgs.git}/bin/git log -p";
          gp = "${pkgs.git}/bin/git push";
          gpf = "${pkgs.git}/bin/git push --force-with-lease";
          gau = "${pkgs.git}/bin/git add -u";
          gcam = "${pkgs.git}/bin/git commit --amend --no-edit";
          grc = "${pkgs.git}/bin/git rebase --continue";
          gru = "${pkgs.git}/bin/git reset \"@{u}\"";

          # Tmux
          tms = "tmux new-session -s";
          tml = "tmux list-session";

          # xclip
          clip = "xclip -sel clip";
        };
      };

      # Escape "$" in bash scripts using "''$"
      programs.bash.initExtra = ''
        # This command let's me execute arbitrary binaries downloaded through channels such as mason.
        export NIX_LD=$(nix eval --impure --raw --expr 'let pkgs = import <nixpkgs> {}; NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"; in NIX_LD')

        export BASH_ENV="~/.bash_aliases"

        mkcd() {
          mkdir "$1" && cd "$_"
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
          nvim "$(fzf)"
        }

        # fd - cd to selected directory
        fd() {
          local dir
          dir=$(find ''${1:-.} -path '*/\.*' -prune \
            -o -type d -print 2> /dev/null | fzf +m) &&
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
        tma() {
          tmux a -t "$1"
        }
        tmf() {
          local session=$(tmux ls | cut -d":" -f1 | fzf)
          tmux a -t "$session"
        }
        tmd() {
          local session=$(tmux ls | cut -d":" -f1 | fzf)
          tmux kill-session -t "$session"
        }

      '';
    };

}
