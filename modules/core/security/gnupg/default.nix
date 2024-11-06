{
  lib,
  config,
  pkgs,
  home-manager,
  username,
  hostname,
  ...
}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    services.gpg-agent = {
      enable = true;

      # enable usage of ssh with gpg
      enableSshSupport = true;

      # enable extra sockets, useful for gpg agent forwarding
      enableExtraSocket = true;

      enableBashIntegration = true;
    };

    # Import my own public key
    programs.gpg.publicKeys.${username}.source = config.sops.secrets."gpg".path;
  };

  # Deploy the gpg private key
  sops.secrets."gpg" = {
    mode = "0400";
    path = "/home/${username}/.gnupg/private-keys-v1.d/max.key";
    owner = "${username}";
  };
}
