{
  description = "ROS 2 development environment using nix";

  inputs = {
    your-nixos-flake.url = "github:maxkiv/nix";
    nixpkgs.follows = "your-nixos-flake/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    ros2 = {
      url = "github:lopsided98/nix-ros-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ros2, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlays = [ ros2.overlays.default ];
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      rosPkgs = pkgs.rosPackages.jazzy;
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nil
          alejandra
          cmake
          gcc
          pkg-config
          colcon
          rosPkgs.ros-core
          rosPkgs.ros2cli
          rosPkgs.ros2launch
          rosPkgs.rclcpp
          rosPkgs.std-msgs
        ];

        # shellHook = ''
        #   source ${rosPkgs.rosSetupHook}
        #   export ROS_DOMAIN_ID=42 # avoid collisions
        # '';
      };

      formatter.x86_64-linux = pkgs.alejandra;
    });
}
