{ config, pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [
    openocd
    qemu
  ];

  # plugdev: Allows members to mount (only with the options nodev and nosuid,
  # for security reasons) and umount removable devices through pmount
  users.extraGroups.plugdev = { };

  users.users.${username} = {
    extraGroups = [ "plugdev" "dialout" ];
  };

  services.udev.packages = [ pkgs.openocd ];

}
