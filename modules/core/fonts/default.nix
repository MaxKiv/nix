{pkgs, ...}: {
  fonts.packages = with pkgs; [
    # KDE fallback font?
    material-design-icons

    # Better emojis? 🏎️
    #noto-fonts-emoji-blob-bin
    noto-fonts-color-emoji

    roboto

    ibm-plex

    # The nerdiest of fonts
    nerd-fonts.hasklug
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["Hasklug"];
      sansSerif = ["Hasklug"];
      serif = ["Hasklug"];
      # emoji = [ "Blobmoji" ]; # for blobs 😘
      emoji = ["Noto Color Emoji"];
    };
  };
}
