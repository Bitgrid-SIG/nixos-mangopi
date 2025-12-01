{
  inputs = {
    shared.url = ../shared-inputs;

    flake-parts.follows = "shared/flake-parts";
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake.flakeModule = { modulesPath, ... }: {
        imports = [];
        options = {};
        config = {
          flake.nixosModules.dist = { config, modulesPath, pkgs, ... }: {
            imports = [
              "${modulesPath}/profiles/base.nix"
              "${modulesPath}/profiles/installation-device.nix"
              "${modulesPath}/installer/sd-card/sd-image.nix"
            ];

            # Boot0 -> U-Boot
            sdImage = {
              firmwarePartitionOffset = 20;
              postBuildCommands = ''
                dd conv=notrunc if=${pkgs.sun20i-d1-spl}/boot0_sdcard_sun20iw1p1.bin of=$img bs=512 seek=16
                dd conv=notrunc if=${pkgs.ubootLicheeRV}/u-boot.toc1 of=$img bs=512 seed=32800
              '';
              populateRootCommands = ''
                mkdir -p ./files/boot
                ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
              '';
              # Sun20i_d1_spl doesn't support loading U-Boot from a partition.
              # The line below is a stub.
              populateFirmwareCommands = "";

              # compressImage = false;
            };
          };
        };
      };
    };
}
