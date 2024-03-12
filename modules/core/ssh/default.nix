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


  home-manager.users.${username} = _:
  {
    services.ssh-agent.enable = true;
    programs.ssh.addKeysToAgent = "yes";
    programs.ssh.matchBlocks.${hostname}.identityFile = config.sops.secrets."ssh/${hostname}".path;

    # home.file = {
    #   # TODO SOPS
    #   # ".ssh/config".source = "${configDir}/config";
    #
    #   # ".ssh/${hostname}".source = config.sops.secrets."ssh/${hostname}".path;
    #   # ".ssh/${hostname}.pub".source = "${dotfilesDir}/.ssh/${hostname}.pub";
    #   ".ssh/${hostname}.pub".source = ../../../dotfiles/.ssh/rapanui.pub;
    # };

  };
}
