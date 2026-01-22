{
  username,
  lib,
  sshKeys,
  ...
}: {
  imports = [
    ./hass
    ./gitea
    ./nginx
    ./adguard
    ./mealie
    ./samba
    ./nfs/server.nix
  ];

  # A homelab device should be a tailscale server
  my.networking.tailscale = {
    enable = true;
    nodeType = lib.mkForce "server";
  };

  # powertop --autotune to reduce power usage, might conflict with cpu-autofreq?
  # Note: This causes services to be unavailable :(
  # powerManagement.powertop.enable = true;

  # Enable openSSH service
  services.openssh.enable = true;

  # Add authorized keys
  users.users.${username} = {
    openssh.authorizedKeys.keys = [
      sshKeys.personal
      sshKeys.work
    ];
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [
      sshKeys.personal
      sshKeys.work
    ];
  };

  # Slight hardening
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
  };

  # Run the nginx reverse proxy
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
}
