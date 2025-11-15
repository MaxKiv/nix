{
  pkgs,
  username,
  ...
}: {
  # Enable CUPS to print documents.
  services.printing.enable = true;


services.printing.drivers = [ pkgs.gutenprint pkgs.cnijfilter2 ];
}
