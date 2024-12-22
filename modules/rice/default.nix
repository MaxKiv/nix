{
  pkgs,
  inputs,
  username,
  ...
}: let
  stylix = inputs.stylix;
in {
  imports = [
    stylix.nixosModules.stylix
  ];

  stylix.enable = true;

  stylix.image = ../../assets/backgrounds/future-windmill.png;
  # colorschemes: https://github.com/tinted-theming/base16-schemes
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

  stylix.polarity = "dark"; # "light" or "either"

  # stylix.cursor.package = pkgs.bibata-cursors;
  # stylix.cursor.name = "Bibata-Modern-Ice";
  stylix.cursor.package = pkgs.catppuccin-cursors.mochaLight;
  stylix.cursor.name = "Catppuccin-Mocha-Light";

  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.hasklug;
      name = "Hasklug Nerd Font";
    };
    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "Roboto";
    };
    serif = {
      package = pkgs.dejavu_fonts;
      name = "Roboto";
    };
  };

  stylix.fonts.sizes = {
    applications = 13;
    terminal = 13;
    desktop = 13;
    popups = 13;
  };

  stylix.opacity = {
    applications = 1.0;
    terminal = 1.0;
    desktop = 1.0;
    popups = 1.0;
  };

  # Exclude these from stylix, these clash with my own config
  home-manager.users.${username} = {
    stylix.targets = {
      vim.enable = false;
      neovim.enable = false;
      alacritty.enable = false;
    };
  };
}
