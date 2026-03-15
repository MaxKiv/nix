# Nextcloud: The selfhosted GSuite (drive, calendar, whatever)
{
  self,
  config,
  pkgs,
  ...
}: let
  fqdn = "cloud.demtah.top";
in {
  sops.secrets = {
    "nextcloud/admin" = {};
  };

  # Note the nextcloud nixos module configures nginx vhost itself
  services.nextcloud = {
    enable = true;
    hostName = fqdn;
    https = true;

    database.createLocally = true;

    config = {
      dbtype = "pgsql";
      adminpassFile = config.sops.secrets."nextcloud/admin".path;
    };

    configureRedis = true;

    settings = {
      default_phone_region = "NL";
    };

    package = pkgs.nextcloud32;
    extraAppsEnable = true;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks onlyoffice;
    };
  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    # enableACME = true;
    useACMEHost = fqdn;
  };

  security.acme.certs."${fqdn}" = {
    dnsProvider = "acme-dns";
    environmentFile = config.sops.secrets.acme-dns-env.path;
  };
}
