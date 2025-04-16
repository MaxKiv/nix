{
  dotfilesDir,
  config,
  username,
  hostname,
  ...
}: {
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  sops.secrets = {
    "ssh/${hostname}" = {
      owner = "${username}";
      path = "/home/${username}/.ssh/${username}";
    };
    "ssh/saxion" = {
      owner = "${username}";
      path = "/home/${username}/.ssh/saxion";
    };
  };

  home-manager.users.${username} = let
    saxionKeyPath = config.sops.secrets."ssh/saxion".path;
    hostnameKeyPath = config.sops.secrets."ssh/${hostname}".path;
  in
    {
      config,
      pkgs,
      ...
    }: {
      services.ssh-agent.enable = true;
      programs.ssh = {
        enable = true;
        addKeysToAgent = "yes";
        matchBlocks = {
          github = {
            host = "github.com";
            user = "git";
            identityFile = hostnameKeyPath;
          };
          gitlab = {
            host = "gitlab.freedesktop.com";
            user = "git";
            identityFile = hostnameKeyPath;
          };
          bitbucket = {
            host = "bitbucket.org";
            user = "git";
            identityFile = saxionKeyPath;
            identitiesOnly = true;
          };
        };
      };

      home.file = {
        # TODO make this reference a private repository, see:
        # https://github.com/ryan4yin/nix-config/blob/985beb8bd47189e4b2ef5200ef5c1ab28e3812a8/home/base/desktop/ssh.nix#L4
        ".ssh/id_ed25519.pub".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.ssh/${hostname}.pub";
        ".ssh/saxion.pub".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.ssh/saxion.pub";
      };
    };
}
