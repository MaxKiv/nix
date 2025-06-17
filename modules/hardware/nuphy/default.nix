
{...}:
{

  # Nuphy Air96 v2 -> 3265   
  # Nuphy Air75 v2 -> 3245
  # Nuphy Air60 v2 -> 3255
  # Nuphy Air60 HE -> fee0
  # NuPhy Gem80    -> 3275
  # NuPhy Halo75   -> 32F5
  # NuPhy Halo96   -> 3302
  # NuPhy Nos75    -> 3235
  # NuPhy Kick75   -> 1026
  # NuPhy Dongle   -> 2620
  # Add udev rule nuphy IO
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", ATTR{idProduct}=="3265", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", ATTR{idProduct}=="3245", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", ATTR{idProduct}=="3255", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", ATTR{idProduct}=="3275", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", ATTR{idProduct}=="32F5", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", ATTR{idProduct}=="3302", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", ATTR{idProduct}=="3235", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", ATTR{idProduct}=="fee0", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", ATTR{idProduct}=="1026", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", ATTR{idProduct}=="2620", MODE="0666"

    KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="3265", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="3245", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="3255", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="3275", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="32F5", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="3302", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="3235", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="fee0", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="1026", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="2620", MODE="0666"
  '';
}
