{config, ...}: let
  port = 8001;
  fqdn = "office.demtah.top";
in {
  services.onlyoffice = {
    inherit port;
    enable = true;
    hostname = fqdn;
    jwtSecretFile = config.sops.secrets."onlyoffice/jwt".path;
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
