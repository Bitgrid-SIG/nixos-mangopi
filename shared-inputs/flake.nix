{
  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixlib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs.follows = "nixos";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixos";

    nix.url = "github:NixOS/nix/2.32.4";
    nix.inputs.nixpkgs.follows = "nixos";
    nix.inputs.flake-parts.follows = "flake-parts";

    all-merge.url = ./all-merge.nix;
    all-merge.flake = false;

    extra-types.url = ./types.nix;
    extra-types.flake = false;

    checks.url = ./checks.nix;
    checks.flake = false;
  };

  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { flake-parts-lib, self, withSystem, ... }: {
        imports = [
          flake-parts.flakeModules.partitions
          flake-parts.flakeModules.flakeModules
        ];

        flake.flakeModule = {
          imports =
          with inputs;
          with flake-parts.flakeModules;
          let
            importApply = src: (flake-parts.lib.importApply src {
              inherit withSystem;
              localFlake = self;
            });
          in [
            flakeModules
            partitions
            (importApply checks)
            (importApply extra-types)
            (importApply all-merge)
          ];
        };
  });
}
