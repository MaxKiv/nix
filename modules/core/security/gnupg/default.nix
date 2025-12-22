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
          # source = "${config.home.homeDirectory}/git/nix/dotfiles/.gnupg/max_public.gpg";
          text = ''
            -----BEGIN PGP PUBLIC KEY BLOCK-----

            mDMEZfsRKhYJKwYBBAHaRw8BAQdAayww+esVMsafnhSIkX4o8YzeIP3Ux6PrezWv
            RtmPZ9O0Ik1heCBLaXZpdHMgPG1heGtpdml0czQyQGdtYWlsLmNvbT6IkwQTFgoA
            OxYhBM0CIxX1ALxr+yTQzMZHSvsDWWqcBQJl+xEqAhsDBQsJCAcCAiICBhUKCQgL
            AgQWAgMBAh4HAheAAAoJEMZHSvsDWWqcItcBANgHjIXqYEfc8XJeKW2VuRQ8WLN4
            c54XjZXyShQlLEoiAP9FAweinn6M9OeaIjbsVkHttlIrH5TOwFUvIRCBWy06C7g4
            BGX7ESoSCisGAQQBl1UBBQEBB0B0Tb9WI2c1fAyjy7mx0xBtKWtaxew6+Q9mbKuq
            KkBcPwMBCAeIeAQYFgoAIBYhBM0CIxX1ALxr+yTQzMZHSvsDWWqcBQJl+xEqAhsM
            AAoJEMZHSvsDWWqcFOABALZnLgn2GYcHSTkjoXTbofp9CuKdTKATiIsY610pH+fE
            AP0ZYatKsBbOjjoQ1NnnhgLY2L4OewzRC0a5KiNGBjcVCg==
            =eBDK
            -----END PGP PUBLIC KEY BLOCK-----
          '';
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
