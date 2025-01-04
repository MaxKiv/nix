{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, inih
, systemd
, scdoc
,
}:
stdenv.mkDerivation {
  pname = "xdg-desktop-portal-termfilechooser";
  version = "unstable-2024-11-30";

  src = fetchFromGitHub {
    owner = "boydaihungst";
    repo = "xdg-desktop-portal-termfilechooser";
    rev = "a0b20c06e3d45cf57218c03fce1111671a617312";
    hash = "sha256-MOS2dS2PeH5O0FKxZfcJUAmCViOngXHZCyjRmwAqzqE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = [
    inih
    systemd
  ];

  mesonFlags = [
    "-Dsd-bus-provider=libsystemd"
  ];

  postInstall = ''
    mkdir -p $out/share/dbus-1/services
    cat > $out/share/dbus-1/services/org.freedesktop.impl.portal.desktop.termfilechooser.service << EOF
    [D-BUS Service]
    Name=org.freedesktop.impl.portal.desktop.termfilechooser
    Exec=$out/libexec/xdg-desktop-portal-termfilechooser
    EOF

    mkdir -p $out/share/xdg-desktop-portal/portals
    cat > $out/share/xdg-desktop-portal/portals/termfilechooser.portal << EOF
    [portal]
    DBusName=org.freedesktop.impl.portal.desktop.termfilechooser
    Interfaces=org.freedesktop.impl.portal.FileChooser
    UseIn=all
    Priority=999
    EOF

    mkdir -p $out/share/systemd/user
    cat > $out/share/systemd/user/xdg-desktop-portal-termfilechooser.service << EOF
    [Unit]
    Description=Terminal file chooser portal
    PartOf=graphical-session.target
    After=graphical-session.target

    [Service]
    Type=dbus
    BusName=org.freedesktop.impl.portal.desktop.termfilechooser
    ExecStart=$out/libexec/xdg-desktop-portal-termfilechooser
    Restart=on-failure

    [Install]
    WantedBy=graphical-session.target
    EOF
  '';

  meta = with lib; {
    description = "Termfilechooser backend for xdg-desktop-portal";
    homepage = "https://github.com/boydaihungst/xdg-desktop-portal-termfilechooser";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}

