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
  ];

  environment.systemPackages = with pkgs; [
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
    nodePackages_latest.prettier
    bash-language-server
    harper # grammar lsp
    asciinema # record terminal
    asciinema-agg # convert asciinema recordings to GIF
    postman # POST/GET API call GUI
  ];
}
