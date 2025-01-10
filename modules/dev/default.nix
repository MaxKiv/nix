{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./embedded
    ./rust
    ./markdown
    ./c
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
  ];
}
