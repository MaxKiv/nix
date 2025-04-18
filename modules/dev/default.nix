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
    ./python
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
    sshfs
    nodePackages_latest.prettier
    bash-language-server
  ];
}
