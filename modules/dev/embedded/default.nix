{ config, pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [
    openocd # Open on chip debugger, device flashing
    qemu # emulate devices
    tio # serial console tty
    saleae-logic-2 # Saleae logic analyzer software
  ];

  # plugdev: Allows members to mount (only with the options nodev and nosuid,
  # for security reasons) and umount removable devices through pmount
  users.extraGroups.plugdev = { };

  users.users.${username} = {
    extraGroups = [ "plugdev" "dialout" ];
  };

  # services.udev.packages: Installs packages that contain udev rules and 
  # ensures that those rules are applied. It automatically installs the 
  # necessary binaries and configurations required for udev.
  services.udev.packages = [ pkgs.openocd pkgs.saleae-logic-2 ];

}
