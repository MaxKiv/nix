# The Big Nix Adventure
Nix is cool stuff, this is my attempt at making the grand-unifying-config.

This is the nix stuff you always forget:
```bash
# rebuild nixos configuration (substitute downtown for the system you want to
build)
sudo nixos-rebuild switch --flake ~/git/nix#downtown --show-trace -L

# or just
just

# Build ISO image
nix build ~/git/nix#iso
# optionally format the usb
lsblk
sudo umount /dev/sda
sudo mkfs.vfat -F 32 /dev/sda
# flash it to usb
cp result/iso/LiveNix.iso /dev/sda
# or, if you hate ergonomics
dd if=result/iso/LiveNix.iso of=/dev/sda bs=4M status=progress conv=fdatasync

# run nixos gc
sudo nixos-collect-garbage -d
# or just
just gc

# How to access nixos config in home-manager?
# https://github.com/nix-community/home-manager/issues/393
{ osConfig, ... }

# SOPS
## generate new key at ~/.config/sops/age/keys.txt
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt

## generate new key at ~/.config/sops/age/keys.txt from private ssh key at ~/.ssh/private
nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/private > ~/.config/sops/age/keys.txt

## get a public key of ~/.config/sops/age/keys.txt
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt

```

## TODO

[ ] Download nvim LSPs through nix instead of mason, the nix-ld workaround is
hacky

[ ] https://github.com/Mic92/envfs
[ ] https://github.com/thiagokokada/nix-alien

[x] Add a justfile, cool!
    https://nixos-and-flakes.thiscute.world/best-practices/simplify-nixos-related-commands

[ ] more ricing

[ ] switch to grub

[?] fix live boot usb setup

[x] integration nixos-hardware

[x] setup SOPS
    [x] setup proper ssh (default key)
    [x] setup wifi uuid/passwd
    [x] setup proper passwd
    [x] setup git gnupg signing

[.] Hyprland

[ ] WSl setup

[ ] Nas/server setup

[ ] setup disko? god help me

[ ] setup impermanence? god help me

[ ] Separate nixos and home-manager flake outputs, so that a user change doesnt
require a new system? how?
    [ ] maybe just dont do this?


## Information

- How do I currently manage dotfiles?
Before this adventure I was managing my dotfiles as a bare git repository
deployed to `$HOME`. This works very well, but is a bit tedious to sync to new
machines.

I want to keep some of my dotfiles in their original configuration language, because I'm
forced to use windows sometimes. I also want to be able to edit my neovim
configuration without having to rebuild my system.

To do this I'm using `(config.lib.file) mkOutOfStoreSymlink`. Make sure to pass
an absolute path to it when using a nix flake. This allows my dotfiles to live
as a submodule of this repository in their original language, and does not
require a rebuild when I make a nvim config change.

For more info see:
https://www.reddit.com/r/NixOS/comments/108fwwh/tradeoffs_of_using_home_manager_for_neovim_plugins/
https://github.com/nix-community/home-manager/issues/257#issuecomment-831300021

