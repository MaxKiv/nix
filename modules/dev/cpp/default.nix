{
  config,
  pkgs,
  username,
  ...
}: {
  # get that lsp action in here
  environment.systemPackages = with pkgs; [
    neocmakelsp
    clang-tools
    clang_17
  ];
}
