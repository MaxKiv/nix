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
    programs.gpg = {
      enable = true;
      publicKeys = [
        {
          source = ../../../../dotfiles/.gnupg/max_public.gpg;
          trust = "ultimate";
        }
      ];
    };

    # Script to import private key post-activation
    home.activation.importGpgKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -f ${config.sops.secrets."gpg-private-key".path} ]; then
        $DRY_RUN_CMD ${pkgs.gnupg}/bin/gpg --batch --import ${config.sops.secrets."gpg-private-key".path}
      fi
    '';
  };

  # Deploy the gpg private key
  sops.secrets."gpg" = {
    mode = "0400";
    path = "/home/${username}/.gnupg/private-keys-v1.d/max.key";
    owner = "${username}";
  };
}
