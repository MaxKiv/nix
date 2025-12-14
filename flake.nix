{
  description = "MaxKiv's NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
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

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    mkSystem = import ./lib/mkSystem.nix {inherit inputs self;};
    forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux"];
  in {
    # Overlays
    overlays.default = import ./overlays {inherit inputs;};
    overlays.dolphin = inputs.dolphin-overlay.overlays.default;

    # NixOS Configurations
    nixosConfigurations = {
      # Desktop
      terra = mkSystem {
        hostname = "terra";
        modules = [
          ./modules/hardware/nvidia
          ./modules/desktop/hyprland
          # ./modules/desktop/sway
          ./modules/gaming
          ./modules/virtualisation
        ];
      };

      # "new" T14 laptop
      rapanui = mkSystem {
        hostname = "rapanui";
        modules = [
          ./modules/desktop/sway
          ./modules/hardware/devices/lenovo-t14
          ./modules/gaming
        ];
      };

      # Craptop
      downtown = mkSystem {
        hostname = "downtown";
        modules = [
          ./modules/hardware/laptop
          ./modules/desktop/sway
        ];
      };

      # Work laptop
      saxion = mkSystem {
        hostname = "saxion";
        modules = [
          ./modules/hardware/devices/lenovo-p16-gen2
          ./modules/desktop/sway
          ./modules/virtualisation
        ];
      };
    };

    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [sops just age alejandra];
      };
    });

    formatter = forAllSystems (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );
  };
}
