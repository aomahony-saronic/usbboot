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
        packages.default = pkgs.stdenv.mkDerivation {
          name = "usbboot";

          nativeBuildInputs = with pkgs; [
            gcc
            gnumake
            pkg-config
            libusb1
            xxd
            tree
          ];

          src = ./.;

          buildPhase = ''
            # Run our make program
            INSTALL_PREFIX=$out make
          '';
          installPhase = ''
            # Make our output directory
            mkdir -p $out/bin
            mkdir -p $out/share/rpiboot/mass-storage-gadget64

            # Copy our binary to the expected directory
            cp rpiboot $out/bin/

            # Copy our bootloader to the expected directory 
            # !!! I'm not sure why this is being copied over, as it isn't used unless we dd it
            # !!! ourselves onto a USB flash drive.  This program uses bootfiles.bin and either uploads
            # !!! it to the Pi directly, or acts as a file server for the Pi bootloader to request from

	          cp mass-storage-gadget64/boot.img $out/share/rpiboot/mass-storage-gadget64/
            cp mass-storage-gadget64/config.txt $out/share/rpiboot/mass-storage-gadget64/
	          cp mass-storage-gadget64/bootfiles.bin $out/share/rpiboot/mass-storage-gadget64/

            # Make sure we copied everything
            tree $out
          '';
        };
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Build dependencies
            gcc
            gnumake
            pkg-config
            libusb1
            
            # Development tools
            bear  # for generating compile_commands.json
            
            # Optional utilities
            xxd
          ];

          shellHook = ''
            echo "rpiboot development environment"
            echo "Generating compile_commands.json..."
            bear -- make
          '';
        };
      });
}
