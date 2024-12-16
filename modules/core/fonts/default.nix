{pkgs, ...}: {
  fonts.packages = with pkgs; [
    material-design-icons

    roboto
    roboto-mono
    roboto-serif
    roboto-slab

    fira
    # fira-code
    fira-mono
    fira-sans

    source-code-pro
    source-sans
    source-sans-pro
    source-serif
    source-serif-pro

    #noto-fonts-emoji-blob-bin
    noto-fonts-color-emoji
    twitter-color-emoji
    unicode-emoji

    ibm-plex

    nerd-fonts.hasklug
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["Fira Mono" "Hasklug" "Source Code Pro"];
      serif = ["Fira Serif" "Hasklug" "Source Serif Pro"];
      sansSerif = ["Fira Sans" "Hasklug" "Source Sans Pro"];
      # emoji = [ "Blobmoji" ]; # for blobs 😘
      emoji = ["Twitter Color Emoji"];
    };
  };
}
