{ pkgs
, username
, ...
}: {
  users.users.${username} = {
    extraGroups = [ "audio" ];
  };

  # Enable the RealtimeKit system service so pipewire can ask for realtime scheduling
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
}
