{config, ...}: let
  adguardPort = 3000;
  fqdn = "ads.demtah.top";
in {
  networking.firewall.allowedTCPPorts = [
    80
    443
    adguardPort
  ];
  networking.firewall.allowedUDPPorts = [53]; # DNS over UDP

  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    settings = {
      dns.upstream_dns = [
        "1.1.1.1"
        "9.9.9.9"
      ];
      filtering.protection_enabled = true;
      filtering.filtering_enabled = true;
      filters =
        map (url: {
          enabled = true;
          url = url;
        }) [
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt" # Steven black's hosts file
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_18.txt" # Filter Phishing domains
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt" # Anti-mailware list
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt" # Filter Phishing domains based on PhishTank and OpenPhish lists"
        ];

      theme = "dark";
    };
  };

  services.nginx = {
    virtualHosts = {
      "${fqdn}" = {
        default = false;
        forceSSL = true;
        useACMEHost = fqdn;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString adguardPort}";
        };

        # taken from https://github.com/AdguardTeam/AdGuardHome/issues/4266#issuecomment-1033955642
        extraConfig = ''
          proxy_pass https://localhost:${toString adguardPort}/;
          proxy_redirect / /aghome/;
          proxy_cookie_path / /aghome/;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Protocol $scheme;
          #proxy_set_header X-Url-Scheme $scheme;
        '';
      };
    };
  };

  security.acme.certs."${fqdn}" = {
    dnsProvider = "acme-dns";
    environmentFile = config.sops.secrets.acme-dns-env.path;
  };
}
