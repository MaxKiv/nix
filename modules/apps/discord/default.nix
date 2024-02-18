{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    discord
    discordo # TUI discord client
  ];
}
