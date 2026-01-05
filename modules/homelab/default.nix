{
  username,
  lib,
  ...
}: {
  imports = [
    ./hass
    ./gitea
  ];

  # A homelab device should be a tailscale server
  my.networking.tailscale = {
    enable = true;
    nodeType = lib.mkForce "server";
  };

  # Enable openSSH service
  services.openssh.enable = true;

  # Add authorized keys
  users.users.${username} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB7JCVDfafziVeBcBoTjw5rutrBJhnOXCxPW52+tk9hw max@rapanui"
    ];
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB7JCVDfafziVeBcBoTjw5rutrBJhnOXCxPW52+tk9hw max@rapanui"
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
