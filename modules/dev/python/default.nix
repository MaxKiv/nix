{
  config,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    poetry # useful to generate poetry.lock files
    pylint
    basedpyright
    ruff
  ];
}
