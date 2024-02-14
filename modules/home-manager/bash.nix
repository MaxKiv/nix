{ config, pkgs, inputs, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  dotfiles = inputs.dotfiles;
in
{
  home.packages = with pkgs; [ alacritty ];

  programs.bash = {
    enable = true;
  };

  home.shellAliases = {
    # Dotfiles management
    dot = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";

alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
dot config --local status.showUntrackedFiles no
alias ds='dot status'
  }

  home.file = {
    ".bash_aliases" = {
      source = mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.bash_aliases";
    };
  };
}
