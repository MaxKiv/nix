{ pkgs, libs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    # TODO enable only for uptown
    wayland.windowManager.hyprland.enableNvidiaPatches = true;

    settings = {

    };
  };

}

