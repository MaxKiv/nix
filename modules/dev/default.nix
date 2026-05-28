{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./aoc
    ./c
    ./cpp
    ./embedded
    ./leetcode
    ./lua
    ./vscode
    ./markdown
    ./python
    ./rust
    ./work
  ];

  environment.systemPackages = with pkgs; [
    tree-sitter
    lua
    gdb
    cmake
    gnumake
    python3
    ruby
    nodejs_20
    git-open
    codespell
    prettierd
    sshfs
    bash-language-server
    harper # grammar lsp
    asciinema # record terminal
    asciinema-agg # convert asciinema recordings to GIF
  ];
}
