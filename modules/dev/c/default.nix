{
  config,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    bear # generate compile_commands.json from makefile
    scons # build system
    # godot_4 # game engine
  ];
}
