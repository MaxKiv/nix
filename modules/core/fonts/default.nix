{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # KDE fallback font?
    material-design-icons

    # Better emojis? 🏎️
    #noto-fonts-emoji-blob-bin
    noto-fonts-color-emoji

    ibm-plex

    # The nerdiest of fonts
    (nerdfonts.override { fonts = [ "Hasklig" ]; })
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "Hasklig" ];
      sansSerif = [ "Hasklig" ];
      serif = [ "Hasklig" ];
      # emoji = [ "Blobmoji" ]; # for blobs 😘
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
