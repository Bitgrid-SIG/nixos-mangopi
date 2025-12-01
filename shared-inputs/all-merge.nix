{ localFlake, withSystem, ... }: with builtins;
{ config, lib, ... }:
let
  inherit (lib) mkOption;
  inherit (config) types;
in {
  options = {
    subflakes = mkOption {
      type = types.attrsOf (types.addCheck types.flake (flake: flake ? nixosModule));
    };

    nixosModule = mkOption {
      type = types.foreignModule;
    };
  };
}
