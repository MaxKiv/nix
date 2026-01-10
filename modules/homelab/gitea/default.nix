{
  self,
  config,
  pkgs,
  sshKeys,
  username,
  email,
  ...
}: let
  domain = "demtah.top";
  hostname = "git";
  fqdn = "${hostname}.${domain}";
  privatePort = 8082;
  giteaUser = "git";
in {
  # use git as user to have `git clone git@git.domain`
  users.users.${giteaUser} = {
    description = "Gitea Service";
    home = config.services.gitea.stateDir;
    useDefaultShell = true;
    group = giteaUser;

    # the systemd service for the gitea module seems to hardcode the group as
    # gitea, so, uh, just in case?
    extraGroups = ["gitea"];

    isSystemUser = true;
    openssh.authorizedKeys.keys = [
      sshKeys.personal
      sshKeys.work
    ];
  };
  users.groups.${giteaUser} = {};

  services.gitea = {
    enable = true;
    user = giteaUser;
    appName = "Git forge of Max";

    database = {
      type = "postgres";
      # user needs to be the same as gitea user
      user = giteaUser;
      name = giteaUser;
      # When postgres and gitea run as the same user, unix socket is used to auth
      # passwordFile = config.sops.secrets."postgres/gitea_dbpass".path;
    };

    lfs.enable = true;

    # Allow Gitea to take a dump (backup zip)
    dump = {
      enable = true;
      interval = "weekly";
    };

    settings = {
      server = {
        ROOT_URL = "https://${fqdn}/";
        DOMAIN = fqdn;
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = privatePort;
      };

      log.LEVEL = "Warn"; # [ "Trace" "Debug" "Info" "Warn" "Error" "Critical" ]

      other.SHOW_FOOTER_VERSION = false;

      repository = {
        ENABLE_PUSH_CREATE_USER = true;
        DEFAULT_BRANCH = "main";
      };

      # only send cookies via HTTPS
      session.COOKIE_SECURE = true;

      # NOTE: temporarily remove this for initial setup
      service.DISABLE_REGISTRATION = false;
    };
  };

  services.postgresql = {
    ensureDatabases = [config.services.gitea.user];
    ensureUsers = [
      {
        name = config.services.gitea.database.user;
        ensureDBOwnership = true;
      }
    ];
  };

  services.nginx = {
    virtualHosts = {
      "${fqdn}" = {
        default = false;
        forceSSL = true;
        useACMEHost = fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString privatePort}";
        };
      };
    };
  };

  security.acme.certs."${fqdn}" = {
    dnsProvider = "acme-dns";
    environmentFile = config.sops.secrets.acme-dns-env.path;
  };
}
