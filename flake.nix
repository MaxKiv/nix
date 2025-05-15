# Much of the flake structure is shamelessly stolen from
# https://github.com/erictossell/nixflakes/blob/main/flake.nix
{
  description = "MaxKiv's Nixos config flake";

  # the nixConfig here only affects the flake itself, not the system configuration!
  # for more information, see:
  # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/add-custom-cache-servers
  nixConfig = {
    # for more detail see:
    # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/add-custom-cache-servers
    extra-substituters = ["https://nix-gaming.cachix.org"];
    extra-trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  # Inputs to the flake
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # dotfiles = {
    #   url = "github:maxkiv/dotfiles";
    #   flake = false;
    # };

    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake-utils.url = "github:numtide/flake-utils";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    nil-lsp = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # firefox-addons = {
    #   url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    firefox-addons = {
      url = "gitlab:MaxKivits/nur-expressions/firefox-ctlnumber?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # source = "https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml";
    alacritty-catppuccin = {
      url = "github:catppuccin/alacritty";
      flake = false;
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS-WSL = {
    #   url = "github:nix-community/NixOS-WSL";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # NixOS modules for specific hardware
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # provides game launcher packages and general gaming tools
    nix-gaming.url = "github:fufexan/nix-gaming";

    # Collection of bleeding edge nix packages -> just used for NordVPN for now
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Apply system-wide styling declaratively
    stylix.url = "github:danth/stylix";

    # Declaratively manage plasma using home-manager
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Declaratively style the spotify client
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Overlay to fix dolphin's "open with" menu not working under sway/hyprland
    dolphin-overlay.url = "github:rumboon/dolphin-overlay";
  };

  # Outputs this flake produces
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
    username = "max";
    inherit (self) outputs;
  in {
    # Specifies global additions and modifications to nixpkgs
    overlays = [
      (import ./overlays {inherit inputs outputs;})
      inputs.dolphin-overlay.overlays.default
    ];

    # Nixos Generators entrypoint
    nixosModules.myFormats = {config, ...}: {
      imports = [
        inputs.nixos-generators.nixosModules.all-formats
      ];
      nixpkgs.hostPlatform = "x86_64-linux";

      # customize an existing format
      formatConfigs.install-iso = {config, ...}: {
        users.users.root = {
          hashedPassword = nixpkgs.lib.mkForce null; # Explicitly remove this setting, we use the password in SOPS
        };
        users.users.nixos = {
          hashedPassword = nixpkgs.lib.mkForce null; # Explicitly remove this setting, we use the password in SOPS
        };
        networking.wireless.enable = false; # Disable wpa_supplicant, we use network manager
        isoImage.squashfsCompression = "zstd -Xcompression-level 6";
      };
    };

    nixosConfigurations = {
      terra = let
        system = "x86_64-linux";
        hostname = "terra";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit system hostname username inputs;} // inputs;
          modules = [
            ./.
            ./modules/hardware/network
            ./modules/hardware/nvidia
            ./modules/desktop/kde
            ./modules/gaming
          ];
        };

      # Craptop
      downtown = let
        system = "x86_64-linux";
        hostname = "downtown";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit system hostname username inputs;} // inputs;
          modules = [
            ./.
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t440s
            ./modules/hardware/network
            ./modules/desktop/kde
          ];
        };

      # Thinkpad
      rapanui = let
        system = "x86_64-linux";
        hostname = "rapanui";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit system hostname username inputs;} // inputs;
          modules = [
            ./.
            ./modules/hardware/devices/lenovo-t14
            ./modules/hardware/network
            # ./modules/desktop/kde
            ./modules/desktop/sway
            ./modules/gaming
          ];
        };

      # Work laptop
      saxion = let
        system = "x86_64-linux";
        hostname = "saxion";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit hostname system username inputs;} // inputs;
          modules = [
            ./.
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p16s-intel-gen2
            ./modules/hardware/devices/lenovo-p16-gen2
            ./modules/hardware/network
            # ./modules/desktop/kde-wayland
            # ./modules/desktop/i3
            ./modules/desktop/sway
          ];
        };

      # plain
      plain = let
        system = "x86_64-linux";
        hostname = "plain";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit system hostname username inputs;} // inputs;
          modules = [
            ./hosts/plain
            ./users
            ./assets
            ./.
            # ./modules/devices/lenovo-p16-gen2
            ./modules/desktop/i3
            # ./modules/desktop/sway
            ./modules/core
          ];
        };

      # Install ISO
      isolate = let
        system = "x86_64-linux";
        hostname = "isolate";
        username = "nixos";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit hostname username system inputs;} // inputs;
          modules = [
            # Expose nixos-generators output formats: https://github.com/nix-community/nixos-generators?tab=readme-ov-file#using-as-a-nixos-module
            self.nixosModules.myFormats
            ./.
            ./modules/hardware/network
            # ./modules/desktop/kde
            ./modules/desktop/sway
          ];
        };
    }; # nixosConfigurations

    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          sops
          just
          age
          alejandra
          statix
        ];
      };
    });

    # nix flake init --template github:maxkiv/nix#
    templates = let
      templateDirs = builtins.attrNames (builtins.readDir ./templates);
      generateTemplate = dir: {
        description = "Create a new ${dir} template linked to system flake nixpkgs";
        path = ./templates/${dir};
      };
    in
      builtins.listToAttrs (map (dir: {
          name = dir;
          value = generateTemplate dir;
        })
        templateDirs);

    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        final = {
          inherit system;
          pkgs = pkgs;
        };
      in
        import ./pkgs {
          inherit inputs final;
        }
    );

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
