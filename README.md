# The Big Nix Adventure

## TODO

[ ] Change nvim symlinks to relative path

[ ] flakify the dotfiles repo?

[ ] Expand nixos modules

[ ] Expand home manager modules

[ ] Separate nixos and home-manager flake outputs, so that a user change doesnt
require a new system


## Information

- How do I currently manage dotfiles?
Before this adventure I was managing my dotfiles as a bare git repository
deployed to `$HOME`. This works very well.

I want to keep my dotfiles in their original configuration language, because I'm
forced to use windows sometimes. I also want to be able to edit my neovim
configuration without having to rebuild my system.

To do this I'm using `(config.lib.file) mkOutOfStoreSymlink`. Make sure to pass
an absolute path to it when using a nix flake. This allows my dotfiles to live
as a submodule of this repository in their original language.

In the future I might make a separate windows configuration, and move everything
here into a true nix flake.

For more info see:
https://www.reddit.com/r/NixOS/comments/108fwwh/tradeoffs_of_using_home_manager_for_neovim_plugins/
https://github.com/nix-community/home-manager/issues/257#issuecomment-831300021

## Current split config nix vs native

|  Item  | Type |
| ------------- | ------------- |
| nvim  | native |
| tmux  | nix |
