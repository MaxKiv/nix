# self-hosted music streaming server that allows users to manage and play their personal music collections from various devices
{
  self,
  config,
  ...
}: let
  storageDirHDD = "/data";
  domain = "demtah.top";
  hostname = "music";
  port = 4533;
  fqdn = "${hostname}.${domain}";
  sopsFile = self + "/secrets/navidrome.env";
in {
  services.navidrome = {
    enable = true;
    group = "data";
    settings = {
      Port = port;
      EnableInsightsCollector = false;
      MusicFolder = "${storageDirHDD}/music";
      LastFM = {
        Enabled = true;
      };
      ListenBrainz = {
        Enabled = false;
      };
    };
  };

  sops.secrets = {
    navidrome-env = {
      inherit sopsFile;
      format = "dotenv";
    };
  };

  systemd.services.navidrome.serviceConfig = {
    EnvironmentFile = [config.sops.secrets.navidrome-env.path];
  };

  services.nginx = {
    virtualHosts = {
      "${fqdn}" = {
        default = false;
        forceSSL = true;
        useACMEHost = fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
        };
      };
    };
  };

  security.acme.certs."${fqdn}" = {
    dnsProvider = "acme-dns";
    environmentFile = config.sops.secrets.acme-dns-env.path;
  };
}
