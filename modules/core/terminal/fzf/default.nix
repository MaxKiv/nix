{ config, pkgs, home-manager, username, ... }:

{
  home-manager.users.${username} = { config, pkgs, ... }:
  {
    home.packages = with pkgs; [ 
      fzf
      ripgrep 
    ];

    home.sessionVariables = {
      "FZF_DEFAULT_COMMAND" = "${pkgs.ripgrep}/bin/rg --files --hidden --follow -g \"!{.git}\" 2>/dev/null";
      "FZF_CTRL_T_COMMAND" = "${pkgs.ripgrep}/bin/rg --files --hidden --follow -g \"!{.git}\" 2>/dev/null";
      "FZF_DEFAULT_OPTS" = "";
    };

    programs.fzf.enable = true;
    programs.fzf.enableBashIntegration = true;
  };
}
