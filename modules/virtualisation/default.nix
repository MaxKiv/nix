{
  pkgs,
  inputs,
  username,
  ...
{
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [username];
}
