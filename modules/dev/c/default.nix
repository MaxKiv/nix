{
  config,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    bear # generate compile_commands.json from makefile
  ];
}
