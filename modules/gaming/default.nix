{
  pkgs,
  config,
  username,
  ...
}: {
  # Enable OpenGL
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true; # allows running of game in optimized micro compositor
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = with pkgs; [
    mangohud # overlay for fps, temp etc
    protonup # installer for proton GE
    lutris # unix game runner that managers wine/proton versions
    heroic # another game launcher for epic / GOG
    bottles # wine prefix manager for all games not runnable by above
    # dwarf-fortress-packages.dwarf-fortress-full # DF classic with bells
    starsector # open-world single-player space-combat, roleplaying, exploration, and economic game
  ];

  # GameMode is a daemon/lib combo for Linux that allows games to request a set
  # of optimisations be temporarily applied to the host OS and/or a game process
  # usage: gamemoderun ./game
  # in steam launch options: gamemoderun %command%
  programs.gamemode.enable = true;

  # required for proton GE installer
  home-manager.users.${username} = {
    home.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
  };
}
