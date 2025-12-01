{
  inputs = {
    shared.url = ../shared-inputs;

    flake-parts.follows = "shared/flake-parts";
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, withSystem, moduleWithSystem, ... }@top: {
        # flake.flakeModules.default = {};
      }
    );
}
