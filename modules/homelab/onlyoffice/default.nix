{
  config,
  pkgs,
  ...
}: let
  port = 8001;
  fqdn = "office.demtah.top";
in {
  services.onlyoffice = {
    enable = true;
    inherit port;
    hostname = fqdn;
    jwtSecretFile = config.sops.secrets."onlyoffice/jwt".path;
    securityNonceFile = config.sops.secrets."onlyoffice/nonce".path;
  };

  sops.secrets = {
    "onlyoffice/jwt" = {
      group = "nginx";
      mode = "0440";
    };
    "onlyoffice/nonce" = {
      group = "nginx";
      mode = "0440";
    };
  };

  # onlyoffice uses Erlang Port Mapper Daemon for some reason
  # Without this you will get:
  # ERROR: epmd error for host XXX: address (cannot connect to host/port)
  services.epmd.listenStream = "0.0.0.0:4369";
  systemd.sockets.epmd.listenStreams = pkgs.lib.mkForce ["0.0.0.0:4369"];

  networking.hosts = {
    "127.0.0.1" = ["nassie"];
  };

  system.activationScripts.onlyoffice-readable.text = ''
    chmod a+x /var/lib/onlyoffice/documentserver/
  '';

  # services.nginx = {
  #   virtualHosts = {
  #     "${fqdn}" = {
  #       default = false;
  #       forceSSL = true;
  #       useACMEHost = fqdn;
  #
  #       locations."/" = {
  #         proxyPass = "http://127.0.0.1:${toString port}";
  #       };
  #     };
  #   };
  # };

  services.nginx.virtualHosts.${config.services.onlyoffice.hostname} = {
    enableACME = true;
    forceSSL = true;
  };

  security.acme.certs."${fqdn}" = {
    dnsProvider = "acme-dns";
    environmentFile = config.sops.secrets.acme-dns-env.path;
  };
}
