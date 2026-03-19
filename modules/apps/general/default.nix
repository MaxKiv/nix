# Default system packages that require a desktop environment
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gparted # manage disk partitions
    inkscape # wish I was smart enough for this
    sniffnet # network monitor tool
    qimgv # image viewer
    picard # GUI to edit music metadata
    teams-for-linux
    zotero # manage & annotate papers & their references
    qdirstat # see whats taking space on filesystem
    kdePackages.kcalc # KDE calculator
    calibre # ebook tool
  ];
}
