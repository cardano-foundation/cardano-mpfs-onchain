{ pkgs, components, shell }:
{
  library = components.library;
  cage-tests = components.tests.cage-tests;
  cage-test-vectors = components.exes.cage-test-vectors;
  lint = pkgs.writeShellApplication {
    name = "lint";
    runtimeInputs = shell.nativeBuildInputs;
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      cd "${../. + "/"}"
      fourmolu -m check $(find lib app test -name '*.hs')
      hlint lib app test
    '';
  };
  vectors-freshness = pkgs.runCommand "vectors-freshness" {
    nativeBuildInputs = [ pkgs.aiken ];
  } ''
    ${pkgs.lib.getExe components.exes.cage-test-vectors} --aiken > "$TMPDIR/cage_vectors.ak"
    aiken fmt "$TMPDIR/cage_vectors.ak"
    diff -u ${../../validators/cage_vectors.ak} "$TMPDIR/cage_vectors.ak" \
      || (echo "ERROR: committed vectors are stale" && exit 1)
    touch $out
  '';
}
