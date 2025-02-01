{
  config,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    pylint
    basedpyright
    ruff
  ];
}
