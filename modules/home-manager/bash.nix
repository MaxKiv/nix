{ pkgs, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  dotfiles = inputs.dotfiles;
in
{
  home.packages = with pkgs; [ alacritty ];
  enable = true;

  home.file = {
    ".bashrc" = {
      source = mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.bashrc";
    };

    ".bash_aliases" = {
      source = mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.bash_aliases";
    };
  };
}
