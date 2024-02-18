{ config, pkgs, home-manager, username, ... }:

{
  home-manager.users.${username} = { config, pkgs, ... }:
  {
    home.packages = with pkgs; [ neovim ];

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    home.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      vimdiff = "nvim -d";
    };

    xdg.desktopEntries."nvim" = {
      name = "nvim";
      comment = "Edit text files";
      icon = "nvim";
      exec = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.neovim}/bin/nvim %F";
      categories = [ "TerminalEmulator" ];
      terminal = false;
      mimeType = [ "text/plain" ];
    };

    xdg.mimeApps.defaultApplications = {
      "text/plain" = [ "nvim" ];
    };

    xdg.configFile = {
      "nvim/init.lua" = { source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/init.lua"; };
      "nvim/lazy-lock.json" = { source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/lazy-lock.json"; };
      "nvim/.stylua.toml" = { source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/.stylua.toml"; };
      "nvim/lua" = { source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/lua"; };
      "nvim/spell" = { source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/spell"; };
      "nvim/after" = { source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/after"; };
    };
  };

}
