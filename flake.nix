{
  description = "rpiboot - Raspberry Pi USB booting tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Build dependencies
            gcc
            gnumake
            libusb1
            
            # Development tools
            bear  # for generating compile_commands.json
            
            # Optional utilities
            xxd
          ];

          shellHook = ''
            echo "rpiboot development environment"
            echo "Generating compile_commands.json..."
            bear make
          '';
        };
      });
}
