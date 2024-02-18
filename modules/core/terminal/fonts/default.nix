{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # KDE fallback font?
    material-design-icons

    # Better emojis? 🏎️
    #noto-fonts-emoji-blob-bin
    noto-fonts-color-emoji

    # The nerdiest of fonts
    (nerdfonts.override { fonts = [ "Hasklig" ]; })
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "Hasklig" ];
      sansSerif = [ "Hasklig" ];
      serif = [ "Hasklig" ];
      # emoji = [ "Blobmoji" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
