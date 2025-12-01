{
  inputs = {
    shared.url = ../shared-inputs;

    flake-parts.follows = "shared/flake-parts";

    linux.url = ./linux.nix;
    linux.flake = false;

    kconfig.url = ./config.nezha;
    kconfig.flake = false;
  };

  outputs = { self, flake-parts, shared, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake.flakeModule = {
        options = {};
        config = {
          subflakes.kernel = self;

          overlays = [
            (self: super: rec {
              linux_nezha = super.callPackage inputs.linux { };
              linuxPackages_nezha = self.packagesFor linux_nezha;
            })
          ];
        };
      };
    };
}
