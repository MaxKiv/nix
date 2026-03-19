{config, ...}: let
  port = 8001;
  fqdn = "office.demtah.top";
in {
  services.onlyoffice = {
    inherit port;
    enable = true;
    hostname = fqdn;
    jwtSecretFile = config.sops.secrets."onlyoffice/jwt".path;
    securityNonceFile = config.sops.secrets."onlyoffice/nonce".path;
  };

  sops.secrets = {
    "onlyoffice/jwt" = {};
    "onlyoffice/nonce" = {};
  };

  # onlyoffice uses Erlang Port Mapper Daemon for some shit
  # This daemon wants to use ipv6, which I usually disable
  # Keep it on localhost, nothing outside should require this
  services.epmd.listenStream = "127.0.0.1:4369";

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
