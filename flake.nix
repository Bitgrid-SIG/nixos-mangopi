{
  inputs = {
    shared.url = ./shared-inputs;

    nixpkgs.follows = "shared/nixos";
    flake-parts.follows = "shared/flake-parts";

    # -- top-level profiles --
    applications.url = ./applications;
    boot.url = ./boot;
    dist.url = ./dist;
    hardware.url = ./hardware;
    kernel.url = ./kernel;
    network.url = ./network;
    nixos.url = ./nixos;
    peripherals.url = ./peripherals;
    services.url = ./services;

    # -- misc profiles --
    profiles.url = ./profiles;
  };

  outputs = { self, nixpkgs, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, ... }: {
        hostSystem = "riscv64-linux";
        buildSystem = "x86_64-linux";

        # systems = [ "x86_64-linux" ];

        imports = with inputs; [
          shared.flakeModule

          # applications.flakeModule
          boot.flakeModule
          dist.flakeModule
          # hardware.flakeModule
          kernel.flakeModule
          network.flakeModule
          nixos.flakeModule
          # peripherals.flakeModule
          # services.flakeModule
          #
          # profiles.flakeModule
        ];

        flake.nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          system = null;

          # installer.cloneConfig = true;

          modules = with self.nixosModules; [
            { nixpkgs.hostPlatform = nixpkgs.lib.mkDefault config.buildSystem; }
            { nixpkgs.hostPlatform = config.hostSystem; }

            boot
            dist

            # applications
            # hardware
            # kernel
            # network
            # nixos
            # peripherals
            # services
            #
            # profiles
          ];
        };

        perSystem = { self', inputs', system, pkgs, lib, ... }: {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              disko
            ];

            buildInputs = with pkgs; [
              gcc
              binutils
              dtc
              swig
              (python3.withPackages (p: with p; [
                libfdt
                setuptools
              ]))
              pkg-config
              ncurses
              nettools
              bc
              bison
              flex
              perl
              rsync
              gmp
              libmpc
              mpfr
              openssl
              libelf
              cpio
              elfutils
              zstd
              gawk
              zlib
              pahole
            ];
          };
        };
      }
    );
}
