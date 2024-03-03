{ dotfilesDir, config, username, hostname, ... }:

{
  # users.users.${username} = {
  #   openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAETSTzRnvYIQsOwhdwcbVRyZVnP6/F3b+inurb9+RMu ${username}" ];
  # };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };


  # users.users.${username}.openssh.authorizedKeys.keys = [
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJGs6nMoXWJFaBAO6zVz0qhG6SUM5pY+XXR8mNugvzVu maxkivits42@gmail.com"
  # ];

  home-manager.users.${username} = { config, pkgs, ... }:
  {
    services.ssh-agent.enable = true;
    programs.ssh.matchBlocks.${hostname}.identityFile = config.sops.secrets."ssh/${hostname}".path;

    home.file = {
    #   # TODO SOPS
      # ".ssh/${hostname}".source = config.sops.secrets."ssh/${hostname}".path;
      # ".ssh/id_ed25519.pub".source = "${dotfilesDir}/.ssh/${hostname}.pub";
      # ".ssh/id_ed25519.pub".source = ../../../dotfiles/.ssh/${hostname}.pub;
      # ".ssh/id_ed25519.pub".source = /home/max/git/nix/dotfiles/.ssh/${hostname}.pub;
      ".ssh/id_ed25519.pub".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix/dotfiles/.ssh/${hostname}.pub";
    };

  };
}
