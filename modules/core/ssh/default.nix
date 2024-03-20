{ dotfilesDir, config, username, hostname, ... }:

{

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  sops.secrets = {
    "ssh/${hostname}" = {
      owner = "${username}";
      path = "/home/${username}/.ssh/id_ed25519";
    };
  };

  home-manager.users.${username} = { config, pkgs, ... }:
  {
    services.ssh-agent.enable = true;
    programs.ssh.matchBlocks.${hostname}.identityFile = config.sops.secrets."ssh/${hostname}".path;

    home.file = {
      # TODO make this reference a private repository, see:
      # https://github.com/ryan4yin/nix-config/blob/985beb8bd47189e4b2ef5200ef5c1ab28e3812a8/home/base/desktop/ssh.nix#L4
      ".ssh/id_ed25519.pub".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.ssh/${hostname}.pub";
    };

  };
}
