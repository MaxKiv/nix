# The Big Nix Adventure

## TODO

[ ] Find a better way to refer to my existing dotfiles repo
    [ ] currently using https://github.com/winston0410/universal-dotfiles/blob/master/modules/bin/neovim.nix
    [ ] flakify the dotfiles repo?
    [ ] Nice workflow? I dont want to do `nix flake update` for every nvim
    change
    [ ] Ideally no submodules as those make it harder to manage dots
    [ ] Maybe the current bare repo is perfect?
    [ ] Maybe I have to bite the bullet and maintain 2 repos?

[ ] Expand nixos modules

[ ] Expand home manager modules

[ ] Seperate nixos and home-manager flake outputs, so that a user change doesnt
require a new system


## Information

- How do I currently manage dotfiles?
Before this adventure I was managing my dotfiles as a bare git repository
deployed to `$HOME`. This works very well.

I want to keep my dotfiles in their original configuration language, because I'm
to use my dotfiles there for now. I also want to be able to edit my neovim
configuration without having to rebuild my system.

To do this I'm using `(config.lib.file) mkOutOfStoreSymlink`. Make sure to pass
an absolute path to it when using a nix flake. This allows my dotfiles to live
in this repository in their original language.

In the future I might make a seperate windows configuration, and move everything
here into a true nix flake.

For more info see:
https://www.reddit.com/r/NixOS/comments/108fwwh/tradeoffs_of_using_home_manager_for_neovim_plugins/
https://github.com/nix-community/home-manager/issues/257#issuecomment-831300021
