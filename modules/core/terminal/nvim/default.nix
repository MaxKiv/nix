{
  inputs,
  config,
  pkgs,
  home-manager,
  neovim-nightly-overlay,
  system,
  username,
  ...
}: {
  environment.systemPackages = [
    pkgs.nil
    pkgs.rust-analyzer
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
  ];

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
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
      exec = "${pkgs.alacritty}/bin/alacritty -e ${inputs.neovim-nightly-overlay.packages.${pkgs.system}.default}/bin/nvim %F";
      categories = ["Application"];
      terminal = false;
      mimeType = ["text/plain"];
    };

    xdg.mimeApps = {
      defaultApplications = {
        "application/x-shellscript" = "nvim.desktop";
        "application/x-perl" = "nvim.desktop";
        "application/json" = "nvim.desktop";
        "text/x-readme" = "nvim.desktop";
        "text/plain" = "nvim.desktop";
        "text/markdown" = "nvim.desktop";
        "text/x-csrc" = "nvim.desktop";
        "text/x-chdr" = "nvim.desktop";
        "text/x-python" = "nvim.desktop";
        "text/x-makefile" = "nvim.desktop";
        "text/x-markdown" = "nvim.desktop";
        "text/x-c++src" = "nvim.desktop";
        "text/x-sh" = "nvim.desktop";
        "text/x-rust" = "nvim.desktop";
        "text/csv" = "nvim.desktop";
      };

      associations.added = {
        "text/x-nix" = "nvim.desktop";
      };
    };

    xdg.configFile = {
      "nvim/init.lua" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/init.lua";};
      "nvim/lazy-lock.json" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/lazy-lock.json";};
      "nvim/.stylua.toml" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/.stylua.toml";};
      "nvim/lua" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/lua";};
      "nvim/spell" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/spell";};
      "nvim/after" = {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.config/nvim/after";};
    };
  };
}
