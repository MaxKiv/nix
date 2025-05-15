{
  lib,
  config,
  pkgs,
  home-manager,
  username,
  hostname,
  ...
}: {
  # Deploy the gpg private key
  # sops.secrets."gpg-private-key" = {
  #   mode = "0400";
  #   path = "/home/${username}/.gnupg/private-keys-v1.d/max.key";
  #   owner = "${username}";
  # };

  sops.secrets."gpg-private-key" = {
    mode = "0400";
    path = "/home/${username}/.local/share/secret-keys/max_private.asc";
    owner = "${username}";
  };

  home-manager.users.${username} = {
    osConfig,
    config,
    pkgs,
    lib,
    ...
  }: let
    dotfilesPath = builtins.path {
      path = ../../../../dotfiles;
      name = "dotfiles";
    };
  in {
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
          source = "${config.home.homeDirectory}/git/nix/dotfiles/.gnupg/max_public.gpg";
          trust = "ultimate";
        }
      ];
    };

    # TODO: script causes hm activation to fail, fix this
    # home.activation.importGpgKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   if [ -f ${osConfig.sops.secrets."gpg-private-key".path} ]; then
    #     ${pkgs.gnupg}/bin/gpg --batch --import ${osConfig.sops.secrets."gpg-private-key".path}
    #   fi
    # '';
  };
}
