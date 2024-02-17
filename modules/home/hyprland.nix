{ pkgs, libs, inputs, ... }:

{
  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

  wayland.windowManager.hyprland = {
    enable = true;

    wayland.windowManager.hyprland.enableNvidiaPatches = true;

    settings = {

    };
  };

}

