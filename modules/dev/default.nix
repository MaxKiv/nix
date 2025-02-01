{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./aoc
    ./c
    ./embedded
    ./leetcode
    ./markdown
    ./lua
    ./rust
  ];

  environment.systemPackages = with pkgs; [
    lua
    gdb
    cmake
    gnumake
    clang_17
    clang-tools_17
    python3
    ruby
    nodejs_20
    git-open
    codespell
    prettierd
    nodePackages_latest.prettier
  ];
}
