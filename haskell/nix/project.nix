{ CHaP, pkgs, ... }:

let
  fix-libs = { lib, pkgs, ... }: {
    packages.cardano-crypto-praos.components.library.pkgconfig =
      lib.mkForce [ [ pkgs.libsodium-vrf ] ];
    packages.cardano-crypto-class.components.library.pkgconfig =
      lib.mkForce [[ pkgs.libsodium-vrf pkgs.secp256k1 pkgs.libblst ]];
  };
  shell = { pkgs, ... }: {
    tools = {
      cabal = {};
      fourmolu = {};
      hlint = {};
    };
    buildInputs = [
      pkgs.just
    ];
  };

  project = pkgs.haskell-nix.cabalProject' ({ lib, pkgs, ... }: {
    name = "cardano-mpfs-cage";
    src = ./..;
    compiler-nix-name = "ghc984";
    shell = shell { inherit pkgs; };
    modules = [ fix-libs ];
    inputMap = { "https://chap.intersectmbo.org/" = CHaP; };
  });

in {
  devShells.default = project.shell;
  inherit project;
  packages.cage-lib =
    project.hsPkgs.cardano-mpfs-cage.components.library;
  packages.cage-tests =
    project.hsPkgs.cardano-mpfs-cage.components.tests.cage-tests;
  packages.cage-test-vectors =
    project.hsPkgs.cardano-mpfs-cage.components.exes.cage-test-vectors;
}
