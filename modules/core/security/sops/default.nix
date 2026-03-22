{
  self,
  inputs,
  config,
  home-manager,
  hostname,
  username,
  ...
}: let
  sopsFile = self + "/secrets/secrets.yaml";
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = sopsFile;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}
