{
  config,
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        yzhang.markdown-all-in-one
        llvm-vs-code-extensions.vscode-clangd
        ms-vscode.cmake-tools
        ms-python.python
        rust-lang.rust-analyzer
      ];
    };
  };
}
