# playerctld: a proxy daemon for the active player
{
  pkgs,
  username,
  ...
}: {
  services.playerctld.enable = true;
}
