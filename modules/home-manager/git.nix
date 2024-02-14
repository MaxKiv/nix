{ config, ... }:

let
  email = "maxkivits42@gmail.com";
  gitName = "MaxKiv";
in {
  programs.git = {
    enable = true;
    extraConfig = {
      core = {
        editor = "nvim";
        ignorecase = false;
      };

      credential.helper = "store";
      github.user = gitName;
      push.autoSetupRemote = true;

      diff = {
        colorMoved = "default";
        stat = true;
      };

      init.defaultBranch = "main";

      merge = {
        conflictstyle = "diff3";
        stat = true;
      };
    };
    userEmail = email;
    userName = gitName;

    # Better diffs
    delta = {
      enable = true;
      options = {
        navigate = true;     # use n and N to move between diff sections
        light = false;       # set to true if you're in a terminal w/ a light background color (e.g. the default macOS terminal)
        side-by-side = true; # side-by-side diff
        line-numbers = false; # show line numbers
        syntax-theme = "zebra-dark";
      };
    };
  };

}
