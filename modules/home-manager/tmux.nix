{ pkgs, inputs, ... }:

let
  dotfiles = inputs.dotfiles;
in
{
  home.packages = with pkgs; [ tmux ];

  programs.tmux = {
    enable = true;
    clock24 = true; # use 24 hour clock

    # TODO how do I consume the dotfiles repo I used as flake input?
    #extraConfig = builtins.readFile "${dotfiles}/.tmux.conf";
    #extraConfig = builtins.readFile ../../dotfiles/.tmux.conf;

  };

  xdg.configFile = {
    # ".tmux.conf" = { source = ../../dotfiles/.tmux.conf; };
    ".tmux.conf" = { source = "${dotfiles}/.tmux.conf"; };
  };
}
