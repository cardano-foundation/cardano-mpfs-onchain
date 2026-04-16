{ pkgs, checks }:
let
  runnable = {
    inherit (checks) cage-tests cage-test-vectors lint;
  };
in
builtins.mapAttrs
  (_: check: {
    type = "app";
    program = pkgs.lib.getExe check;
  })
  runnable
