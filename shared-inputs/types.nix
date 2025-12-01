{ localFlake, withSystem, ... }: with builtins;
{ config, lib, ... }:
let
  inherit (lib) types mkOption mkOptionType;
  inherit (config) checks;

  fn = mkOptionType {
    name = "fn";
    description = "function";
    descriptionClass = "noun";
    check = isFunction;
  };

  nestedAttrsOf = type: let inherit (types) attrsOf; in
    types.oneOf [
      (attrsOf type)
      (attrsOf (attrsOf type))
      (attrsOf (attrsOf (attrsOf type)))
    ];
in {
  options = {
    extra-types = mkOption {
      description = "extra types that can be used for module options";
      type = nestedAttrsOf (
        types.either
          types.optionType
          (types.functionTo types.optionType)
        );
      default = {};
    };

    types = mkOption {
      type = types.uniq (types.attrsOf types.anything);
    };
  };

  config = {
    types = types // config.extra-types;
    extra-types = {
      inherit fn nestedAttrsOf;

      record = record:
        assert lib.assertMsg
          ( all
            (value: types.isOptionType value)
            (attrValues record)
          )
          "All attr values of a record must be an option type!";

        mkOptionType {
          name = "record";
          description = "record";
          descriptionClass = "noun";
          check = checks.isInstanceOf record;
        };

      flake = mkOptionType {
        name = "flake";
        description = "nix flake";
        descriptionClass = "noun";
        check = checks.isFlake;
      };

      foreignModule =
        types.either
        (types.attrsOf types.anything) # shorthand
        (config.extra-types.record {
          options = mkOption {
            type = types.attrsOf types.optionType;
          };

          config = mkOption {
            type = types.attrsOf types.anything;
          };
        });

      _overlay = mkOptionType {
        name = "overlay";
        description = "nixpkgs overlay";
        descriptionClass = "noun";
        check = checks.isOverlay;
      };

      overlay =
        types.either
          config._overlay
          (types.coercedTo types.path (path: import path) config._overlay);

      systemsEnum = types.enum lib.systems.flakeExposed;
    };
  };
}
