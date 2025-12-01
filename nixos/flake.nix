{
  inputs = {
    shared.url = ../shared-inputs;

    nixpkgs.follows = "shared/nixos";
    flake-parts.follows = "shared/flake-parts";

    spl.url = ./spl.nix;
    spl.flake = false;

    rtl8723ds.url = ./rtl8723ds.nix;
    rtl8723ds.flake = false;
  };

  outputs = { self, flake-parts, nixpkgs, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake.flakeModule =
        ({ config, lib, ... }:
        let
          inherit (lib) types mkOption;
        in {
          options = {
            hostSystem = mkOption {
              type = config.types.systemsEnum;
            };

            buildSystem = mkOption {
              type = config.types.systemsEnum;
            };

            overlays = mkOption {
              type = types.listOf types.overlay;
            };

            legacyPackages = mkOption {
              type = types.attrsOf (types.attrsOf
                (types.either types.package types.any)
              );
            };
          };

          config = {
            subflakes.nixos = self;

            systems =
              lib.lists.unique [
                config.hostSystem
                config.buildSystem
              ];

            overlays = [
              inputs.overlay

              (self: super: {
                opensbi = super.opensbi.overrideAttrs (prev: {
                  patches = [
                    (super.fetchpatch {
                      url = "https://github.com/smaeul/opensbi/commit/5023da429ea963f230f7361b2c15e60c7e428555.patch";
                      sha256 = "sha256-+ulCgexdZRp2pfsgDqgNiWysXfOO9sD3YqZbT5bG3V8=";
                    })
                    (super.fetchpatch {
                      url = "https://github.com/smaeul/opensbi/commit/e6793dc36a71537023f078034fe795c64a9992a3.patch";
                      sha256 = "sha256-FwVe1UMXhkPVih8FrO7+cwMobAiuOj1+H6+drBgPT+4=";
                    })
                  ];
                });
              })

              (self: super: rec {
                sun20i-d1-spl = super.callPackage inputs.spl { };

                packagesFor = kernel:
                  let
                    origin = super.linuxKernel.packagesFor kernel;
                  in origin // {
                    rtl8723ds = origin.callPackage inputs.rtl8723ds { };
                  };
              })
            ];

            legacyPackages =
              builtins.listToAttrs
                (system: {
                  name = system;
                  value = import nixpkgs {
                    inherit (config) overlays;
                  };
                })
                config.systems;
          };
        });
    };
}
