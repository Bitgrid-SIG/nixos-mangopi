{
  inputs = {
    shared.url = ../shared-inputs;

    flake-parts.follows = "shared/flake-parts";

    linux.url = ./linux.nix;
    linux.flake = false;

    kernelConfig.url = ./config.nezha;
    kernelConfig.flake = false;
  };

  outputs = { self, flake-parts, shared, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake.flakeModule = {
        options = {};
        config = {
          subflakes.kernel = self;

          overlays = [
            (self: super: rec {
              linux_nezha = super.callPackage inputs.linux {
                inherit (inputs) kernelConfig;
              };

              # packagesFor overlaid by nixos subflake
              linuxPackages_nezha = self.packagesFor linux_nezha;
            })
          ];
        };
      };
    };
}
