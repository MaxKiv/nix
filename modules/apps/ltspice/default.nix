{
  pkgs,
  username,
  ...
}: {
  # LTSpice is an analog electronic circuit simulator
  environment.systemPackages = with pkgs; [
    ltspice
  ];
}
