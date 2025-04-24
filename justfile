# just is a command runner, Justfile is very similar to Makefile, but simpler.
# Shamelessly stolen from https://nixos-and-flakes.thiscute.world/best-practices/simplify-nixos-related-commands

# Build and deploy this NixOS derivation
deploy:
    sudo nixos-rebuild switch --flake .

# Print all available just commands
help:
    @just --list

# Build and deploy this NixOS derivation
build:
    sudo nixos-rebuild build --flake .

# Print debug info while attempting to build and deploy this NixOS derivation
debug:
    sudo nixos-rebuild build --flake . --show-trace --verbose --option eval-cache false

# Update all flake inputs
update:
    nix flake update

# Update a specific flake input
up input:
    nix flake lock --update-input {{ input }}

# Open a nix repl
repl:
    nix repl -f flake:nixpkgs

# Remove all generations older than 7 days
clean:
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# Garbage collect all unused nix store entries
gc:
    sudo nix-collect-garbage --delete-old

# Edit secrets with sops
secret:
    sops secrets/secrets.yaml

init-sops:
    echo "Read about setting up sops here"
    xdg-open https://github.com/Mic92/sops-nix?tab=readme-ov-file#usage-example
    echo "TODO: think of a safe method to pass the age keys to new machines"
    echo "Fetch your age key from someplace and put it in ~/.config/sops/age/keys.txt"

fix-gnupg:
    sudo chown max:users ~/.gnupg

# Generate installer ISO
iso:
    nix build .#nixosConfigurations.isolate.config.formats.install-iso --show-trace --verbose --option eval-cache false
