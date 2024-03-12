{ sops-nix, config, home-manager, hostname, username, ... }:
{
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = ../../../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

  sops.secrets = {
    "ssh/${hostname}" = {
      owner = "${username}";
      path = "/home/${username}/.ssh/id_25519";
    };

    "pass/${username}" = {
      neededForUsers = true;
    };

    "pass/root" = {
      neededForUsers = true;
    };
  };

}

