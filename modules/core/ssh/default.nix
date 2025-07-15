{
  inputs,
  config,
  username,
  hostname,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    xorg.xauth
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  sops.secrets = {
    "ssh/personal" = {
      owner = "${username}";
      path = "/home/${username}/.ssh/personal";
    };
    "ssh/work" = {
      owner = "${username}";
      path = "/home/${username}/.ssh/work";
    };
  };

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB7JCVDfafziVeBcBoTjw5rutrBJhnOXCxPW52+tk9hw max@rapanui"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDg4NiAu5ELDpnDRzUZWuZTP2DVgXAGtOHjXe2CJClt m.p.w.kivits@saxion.nl"
  ];

  home-manager.users.${username} = let
    workKeyPath = config.sops.secrets."ssh/work".path;
    personalKeyPath = config.sops.secrets."ssh/personal".path;
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
            identityFile = personalKeyPath;
          };
          gitlab = {
            host = "gitlab.freedesktop.com";
            user = "git";
            identityFile = personalKeyPath;
          };
          bitbucket = {
            host = "bitbucket.org";
            user = "git";
            identityFile = workKeyPath;
            identitiesOnly = true;
          };
          rapanui = {
            hostname = "10.0.1.233";
            user = "${username}";
            port = 22;
            identityFile = personalKeyPath;
            identitiesOnly = true;
          };
          saxion = {
            hostname = "10.0.1.210";
            user = "${username}";
            port = 22;
            identityFile = personalKeyPath;
            identitiesOnly = true;
          };
        };
      };

      home.file = {
        # TODO make this reference a private repository, see:
        # https://github.com/ryan4yin/nix-config/blob/985beb8bd47189e4b2ef5200ef5c1ab28e3812a8/home/base/desktop/ssh.nix#L4
        #".ssh/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.ssh/config";
        ".ssh/personal.pub".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.ssh/personal.pub";
        ".ssh/work.pub".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.ssh/work.pub";
        # ".ssh/authorized_keys".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.ssh/authorized_keys";
      };
    };
}
