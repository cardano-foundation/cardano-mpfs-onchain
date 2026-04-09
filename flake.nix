{
  description = "Aiken validators and Haskell on-chain types for MPF";

  nixConfig = {
    extra-substituters = [ "https://cache.iog.io" ];
    extra-trusted-public-keys =
      [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
  };

  inputs = {
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    cardano-mpfs-cage.url = "github:cardano-foundation/cardano-mpfs-cage/feat/aiken-vectors";
    haskellNix.url =
      "github:input-output-hk/haskell.nix/baa6a549ce876e9c44c494a12116f178f1becbe6";
    iohkNix = {
      url =
        "github:input-output-hk/iohk-nix/0ce7cc21b9a4cfde41871ef486d01a8fafbf9627";
      inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    };
    CHaP = {
      url =
        "github:intersectmbo/cardano-haskell-packages/a46182e9c039737bf43cdb5286df49bbe0edf6fb";
      flake = false;
    };
    cardano-node-clients = {
      url = "github:lambdasistemi/cardano-node-clients/1104f7cb47fee3169074da1c803ff633b85c43f7";
    };
    cardano-node.follows = "cardano-node-clients/cardano-node";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      cardano-mpfs-cage,
      haskellNix,
      iohkNix,
      CHaP,
      cardano-node,
      cardano-node-clients,
      ...
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (
      system:
      let
        pkgs = import nixpkgs {
          overlays = [
            iohkNix.overlays.crypto
            haskellNix.overlay
            iohkNix.overlays.haskell-nix-crypto
            iohkNix.overlays.cardano-lib
          ];
          inherit system;
        };

        # Pre-fetched Aiken dependencies
        stdlib = pkgs.fetchFromGitHub {
          owner = "aiken-lang";
          repo = "stdlib";
          rev = "v2.2.0";
          hash = "sha256-BDaM+JdswlPasHsI03rLl4OR7u5HsbAd3/VFaoiDTh4=";
        };

        fuzz = pkgs.fetchFromGitHub {
          owner = "aiken-lang";
          repo = "fuzz";
          rev = "v2.1.1";
          hash = "sha256-oMHBJ/rIPov/1vB9u608ofXQighRq7DLar+hGrOYqTw=";
        };

        merkle-patricia-forestry = pkgs.fetchFromGitHub {
          owner = "aiken-lang";
          repo = "merkle-patricia-forestry";
          rev = "v2.0.0";
          hash = "sha256-uHVQxA1dYDuPbH+pf6SkGNBF7nBlDXdULrPFkfUDjzU=";
        };

        # TOML manifest that aiken expects in build/packages/
        packagesToml = pkgs.writeText "packages.toml" ''
          [[packages]]
          name = "aiken-lang/stdlib"
          version = "v2.2.0"
          source = "github"

          [[packages]]
          name = "aiken-lang/fuzz"
          version = "v2.1.1"
          source = "github"

          [[packages]]
          name = "aiken-lang/merkle-patricia-forestry"
          version = "v2.0.0"
          source = "github"
        '';

        test-vectors =
          cardano-mpfs-cage.packages.${system}.cage-test-vectors;

        cage-vectors-ak = pkgs.runCommand "cage-vectors.ak" { } ''
          ${test-vectors}/bin/cage-test-vectors --aiken > $out
        '';

        # Aiken blueprint
        blueprint = pkgs.stdenv.mkDerivation {
          pname = "mpf-plutus-blueprint";
          version = "0.0.0";
          src = pkgs.lib.cleanSource ./.;
          nativeBuildInputs = [ pkgs.aiken ];
          buildPhase = ''
            mkdir -p build/packages
            cp ${packagesToml} build/packages/packages.toml
            cp -r ${stdlib} build/packages/aiken-lang-stdlib
            cp -r ${fuzz} build/packages/aiken-lang-fuzz
            cp -r ${merkle-patricia-forestry} build/packages/aiken-lang-merkle-patricia-forestry
            chmod -R u+w build/packages
            aiken build
          '';
          installPhase = ''
            cp plutus.json $out
          '';
        };

        # Devnet genesis files from cardano-node-clients
        devnet-genesis =
          cardano-node-clients.packages.${system}.devnet-genesis;
        cardano-node-pkgs = cardano-node.packages.${system};

        # Haskell project (cardano-mpfs-onchain library + E2E tests)
        indexState = "2025-12-07T00:00:00Z";
        indexTool = { index-state = indexState; };
        fix-libs = { lib, pkgs, ... }: {
          packages.cardano-crypto-praos.components.library.pkgconfig =
            lib.mkForce [ [ pkgs.libsodium-vrf ] ];
          packages.cardano-crypto-class.components.library.pkgconfig =
            lib.mkForce
            [ [ pkgs.libsodium-vrf pkgs.secp256k1 pkgs.libblst ] ];
        };
        haskellProject = pkgs.haskell-nix.cabalProject' {
          name = "cardano-mpfs-onchain";
          src = ./.;
          compiler-nix-name = "ghc984";
          shell = {
            tools = {
              cabal = indexTool;
              cabal-fmt = indexTool;
              fourmolu = indexTool;
              hlint = indexTool;
            };
            buildInputs = [
              pkgs.aiken
              pkgs.just
              pkgs.lean4
              cardano-node-pkgs.cardano-node
              cardano-node-pkgs.cardano-cli
            ];
            shellHook = ''
              export MPFS_BLUEPRINT="${blueprint}"
              export E2E_GENESIS_DIR="${devnet-genesis}"
            '';
          };
          modules = [ fix-libs ];
          inputMap = {
            "https://chap.intersectmbo.org/" = CHaP;
          };
        };

      in
      {
        packages.test-vectors = cage-vectors-ak;

        packages.default = blueprint;

        packages.e2e-tests =
          haskellProject.hsPkgs.cardano-mpfs-onchain.components.tests.e2e-tests;

        devShells.default = haskellProject.shell;
      }
    );
}
