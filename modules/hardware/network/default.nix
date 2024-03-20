{ hostname, username, ... }:

{
  networking = {
    networkmanager = {
      enable = true;

      # NOTE: dramatic effect on bandwidth https://gist.github.com/jcberthon/ea8cfe278998968ba7c5a95344bc8b55
      # wifi.powersave = true; 
    };
    hostName = hostname;
  };



  users.users.${username} = {
    extraGroups = [ "networkmanager" ];
  };
}

