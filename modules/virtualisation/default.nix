{
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ./docker
  ];

  # https://wiki.nixos.org/wiki/Libvirt
  # https://wiki.nixos.org/wiki/Virt-manager

  # Enable libvirtd service
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        # Enable TPM and secure boot emulation, for Windows 11
        swtpm.enable = true;
      };
    };
  };

  # TODO: enable kvm-amd or kvm-intel based on CPU
  # boot.kernelModules = ["kvm-intel"];

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = [username];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
  ];

  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
