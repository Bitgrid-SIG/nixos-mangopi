{ localFlake, withSystem, ... }: with builtins;
{ config, lib, ... }:
let
  inherit (lib) mkOption types;
in {
  options = {
    checks = mkOption {
      description = ''
        functions that can be used for type validation.
        Mostly used for defining new module types.
      '';
      type = types.attrsOf (types.addCheck types.unspecified isFunction);
    };
  };

  config = {
    checks = {
      isFlake = maybeFlake:
        if maybeFlake ? _type
        then maybeFlake._type == "flake"
        else maybeFlake ? inputs && maybeFlake ? outputs && maybeFlake ? sourceInfo;

      isInstanceOf = record: instance:
        let
          intersection = builtins.intersectAttrs record instance;
          names = {
            record = attrNames record;
            instance = attrNames instance;
            intersection = attrNames intersection;
          };
          sizesMatch = (
              ((length names.intersection) == (length names.record))
          &&  ((length names.record) == (length names.instance))
          );
        in
          sizesMatch
        &&  (all (name: record.${name}.check instance.${name}) (attrNames record));

      returnTypeIs = fn: check:
      let
        ret = fn null;
        eval = tryEval (typeOf ret);
      in { inherit ret; match = eval.success && (eval.value == check); };

      isOverlay = fn:
      let
        returnTypeIs = config.checks.returnTypeIs;

        retCheck =
          if (isFunction fn)
          then (returnTypeIs fn "lambda")
          else null;

        retRetCheck =
          if ((!isNull retCheck) && retCheck.match)
          then (returnTypeIs retCheck.ret "set")
          else null;

      in (!isNull retRetCheck) && retRetCheck.match;
    };
  };
}
