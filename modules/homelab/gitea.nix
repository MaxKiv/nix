{config, ...}: let
  hostname = config.networking.hostName;
  domain = "git.test.tld";
  privatePort = 8082;
  giteaUser = "git";
  fqdn = "${hostname}.${domain}";
in {
  networking.firewall = {
    allowedTCPPorts = [
      privatePort
    ];
  };

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
  };
  users.groups.${giteaUser} = {};

  # sops.secrets."postgres/gitea_dbpass" = {
  #   owner = config.services.gitea.user;
  # };

  services.gitea = {
    enable = true;
    user = giteaUser;
    appName = "My personal forge";

    database = {
      type = "postgres";
      # user needs to be the same as gitea user
      user = giteaUser;
      name = giteaUser;
      # passwordFile = config.sops.secrets."postgres/gitea_dbpass".path;
    };

    domain = "git.test.tld";
    rootUrl = "https://git.test.tld/";

    lfs.enable = true;

    # Allow Gitea to take a dump (backup zip)
    dump = {
      enable = true;
      interval = "weekly";
    };

    settings = {
      server = {
        ROOT_URL = "https://git.${domain}/";
        DOMAIN = "git.${domain}";
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

  services.nginx = {
    virtualHosts = {
      "git.${domain}" = {
        forceSSL = true;
        useACMEHost = fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString privatePort}";
        };
      };
    };
  };

  users.users.nginx.extraGroups = ["acme"];

  sops.secrets.acme-dns = {
    owner = "acme";
    group = "acme";
    mode = "0400";
  };

  security.acme = {
    acceptTerms = true;
    security.acme.defaults.email = "maxkivits42@gmail.com";
  };

  security.acme.certs."git.demtah.top" = {
    dnsProvider = "acme-dns";
    credentialsFile = config.sops.secrets.acme-dns.path;
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
}
# {
#     "username": "5ac2d48f-98d6-4f50-ad83-c91d8fa1b6ec",
#     "password": "bv2NcAj8dx1fI_pnqkZDiLd5IJeKckQ5GnnwteXm",
#     "fulldomain": "4c701c5a-9049-4338-a6b6-c63bec59c2d8.auth.acme-dns.io",
#     "subdomain": "4c701c5a-9049-4338-a6b6-c63bec59c2d8",
#     "allowfrom": []
# }

