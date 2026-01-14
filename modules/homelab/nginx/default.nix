{
  self,
  config,
  hostname,
  ...
}: let
  sopsFile = self + "/secrets/acme-dns.env";
in {
  networking.firewall = {
    allowedTCPPorts = [
      442
    ];
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
  };

  # Allow nginx to access acme
  users.users.nginx.extraGroups = ["acme"];

  # ACME secret
  sops.secrets.acme-dns-env = {
    inherit sopsFile;
    owner = "acme";
    group = "acme";
    mode = "0400";
    format = "dotenv";
  };

  # Configure ACME
  security.acme = {
    acceptTerms = true;
    defaults.email = "maxkivits42@gmail.com";
  };
}
