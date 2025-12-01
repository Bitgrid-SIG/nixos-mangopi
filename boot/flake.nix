{
  inputs = {
    shared.url = ../shared-inputs;

    flake-parts.follows = "shared/flake-parts";
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake.flakeModule = {
        imports = [];
        options = {};
        config = {
          flake.nixosModules.boot = { config, lib, pkgs, ... }: {
            boot = {
              loader.grub.enable = false;
              loader.generic-extlinux-compatible.enable = true;

              consoleLogLevel = lib.mkDefault 7;
              kernelPackages = pkgs.linuxPackages_nezha;
              kernelParams = [ "console=ttyS0,115200n8" "console=tty0" "earlycon=sbi" ];

              initrd.availableKernelModules = lib.mkForce [ ];

              extraModulePackages = [ pkgs.linuxPackages_nezha.rtl8723ds ];
              # Exclude zfs
              supportedFilesystems = lib.mkForce [ ];
            };
          };
        };
      };
    };
}
