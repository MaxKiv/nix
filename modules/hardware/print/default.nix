{
  pkgs,
  username,
  ...
}: {
  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.printing.drivers = with pkgs; [
    gutenprint
    # cnijfilter2
    # hplip
    # splix
  ];
}
