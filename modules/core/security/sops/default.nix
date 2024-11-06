{
  sops-nix,
  config,
  home-manager,
  hostname,
  username,
  ...
}: {
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = ../../../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
}
