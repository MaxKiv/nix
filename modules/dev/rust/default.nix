{username, ...}: {
  home-manager.users.${username} = {
    config,
    pkgs,
    ...
  }: {
    # For bigger projects these should come from the local tooling flake, but
    # its useful to have them on a system level too
    home.packages = with pkgs; [
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
      cargo-generate
      cargo-binutils
      vscode-extensions.vadimcn.vscode-lldb.adapter
    ];

    # This lets nvim know where codelldb lives
    home.sessionVariables = {
      NVIM_CODELLDB_PATH = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb";
    };
  };
}
