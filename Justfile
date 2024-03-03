# just is a command runner, Justfile is very similar to Makefile, but simpler.
# Shamelessly stolen from https://nixos-and-flakes.thiscute.world/best-practices/simplify-nixos-related-commands

############################################################################
#
#  Nix commands related to the local machine
#
############################################################################

deploy:
  nixos-rebuild switch --flake . --use-remote-sudo

debug:
  nixos-rebuild switch --flake . --use-remote-sudo --show-trace --verbose --option eval-cache false

up:
  nix flake update

# Update specific input
# usage: make upp i=home-manager
upp:
  nix flake lock --update-input $(i)

history:
  nix profile history --profile /nix/var/nix/profiles/system

repl:
  nix repl -f flake:nixpkgs

clean:
  # remove all generations older than 7 days
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

gc:
  # garbage collect all unused nix store entries
  sudo nix-collect-garbage --delete-old

############################################################################
#
#  Idols, Commands related to my remote distributed building cluster
#
############################################################################

# add-idols-ssh-key:
#   ssh-add ~/.ssh/ai-idols
#
# aqua: add-idols-ssh-key
#   nixos-rebuild --flake .#aquamarine --target-host aquamarine --build-host aquamarine switch --use-remote-sudo
#
# aqua-debug: add-idols-ssh-key
#   nixos-rebuild --flake .#aquamarine --target-host aquamarine --build-host aquamarine switch --use-remote-sudo --show-trace --verbose
#
# ruby: add-idols-ssh-key
#   nixos-rebuild --flake .#ruby --target-host ruby --build-host ruby switch --use-remote-sudo
#
# ruby-debug: add-idols-ssh-key
#   nixos-rebuild --flake .#ruby --target-host ruby --build-host ruby switch --use-remote-sudo --show-trace --verbose
#
# kana: add-idols-ssh-key
#   nixos-rebuild --flake .#kana --target-host kana --build-host kana switch --use-remote-sudo
#
# kana-debug: add-idols-ssh-key
#   nixos-rebuild --flake .#kana --target-host kana --build-host kana switch --use-remote-sudo --show-trace --verbose
#
# idols: aqua ruby kana
#
# idols-debug: aqua-debug ruby-debug kana-debug
