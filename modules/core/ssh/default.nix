{
  inputs,
  config,
  username,
  hostname,
  pkgs,
  sshKeys,
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

  users.users.root.openssh.authorizedKeys.keys = [
    sshKeys.personal
    sshKeys.work
  ];
  users.users.${username}.openssh.authorizedKeys.keys = [
    sshKeys.personal
    sshKeys.work
  ];

  home-manager.users.${username} = let
    workKey = config.sops.secrets."ssh/work".path;
    personalKey = config.sops.secrets."ssh/personal".path;
  in
    {
      config,
      pkgs,
      ...
    }: {
      services.ssh-agent.enable = true;
      programs.ssh = {
        enable = true;
        matchBlocks = let
          myMachineSettings = {
            user = "root";
            port = 22;
            identityFile = personalKey;
            identitiesOnly = true;
            addKeysToAgent = "yes";
          };
        in {
          github = {
            host = "github.com";
            user = "git";
            identityFile = personalKey;
            addKeysToAgent = "yes";
          };
          gitlab = {
            host = "gitlab.freedesktop.com";
            user = "git";
            identityFile = personalKey;
            addKeysToAgent = "yes";
          };
          bitbucket = {
            host = "bitbucket.org";
            user = "git";
            identityFile = workKey;
            identitiesOnly = true;
            addKeysToAgent = "yes";
          };
          rapanui = {
            hostname = "10.0.1.233";
            user = "${username}";
            port = 22;
            identityFile = personalKey;
            identitiesOnly = true;
            addKeysToAgent = "yes";
          };
          saxion = {
            hostname = "10.0.1.210";
            user = "${username}";
            port = 22;
            identityFile = personalKey;
            identitiesOnly = true;
            addKeysToAgent = "yes";
          };
          "router.local" = myMachineSettings;
          "downtown.local" = myMachineSettings;
          "nassie.local" = myMachineSettings;
          "rapanui.local" = myMachineSettings;
          "terra.local" = myMachineSettings;
          "192.168.1.2" = myMachineSettings;
          "192.168.1.3" = myMachineSettings;
          "*.demtah.top" = myMachineSettings;
        };
      };

      home.file = {
        ".ssh/personal.pub".text = sshKeys.personal;
        ".ssh/work.pub".text = sshKeys.work;
      };
    };
}
