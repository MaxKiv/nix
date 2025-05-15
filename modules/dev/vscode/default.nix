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
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        yzhang.markdown-all-in-one
        ms-vscode.cpptools
        ms-vscode.cpptools-extension-pack
        ms-vscode.cmake-tools
        ms-python.python
        rust-lang.rust-analyzer
      ];
    };
  };
}
