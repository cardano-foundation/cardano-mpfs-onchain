{
  description = "MPFS on-chain — Aiken validators + Haskell cage package";

  nixConfig = {
    extra-substituters = [ "https://cache.iog.io" ];
    extra-trusted-public-keys =
      [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
  };

  inputs = {
    haskellNix.url =
      "github:input-output-hk/haskell.nix/baa6a549ce876e9c44c494a12116f178f1becbe6";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    iohkNix = {
      url =
        "github:input-output-hk/iohk-nix/0ce7cc21b9a4cfde41871ef486d01a8fafbf9627";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    CHaP = {
      url =
        "github:intersectmbo/cardano-haskell-packages/a46182e9c039737bf43cdb5286df49bbe0edf6fb";
      flake = false;
    };
    # Pinned cardano-node, used as a subprocess by the devnet E2E
    # tests. Version tracks the upstream cardano-node-clients
    # devnet Dockerfile.
    cardano-node = {
      url = "github:IntersectMBO/cardano-node/10.5.4";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      haskellNix,
      iohkNix,
      CHaP,
      cardano-node,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
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

        # -------------------------------------------------------
        # Aiken build
        # -------------------------------------------------------

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

        # Stage stdlib, fuzz, and merkle-patricia-forestry into
        # build/packages so `aiken <subcommand>` runs hermetically
        # in the sandbox. Reused across the build and the check
        # derivations so there is one source of truth for the
        # Aiken prelude.
        aikenPrelude = ''
          mkdir -p build/packages
          cp ${packagesToml} build/packages/packages.toml
          cp -r ${stdlib} build/packages/aiken-lang-stdlib
          cp -r ${fuzz} build/packages/aiken-lang-fuzz
          cp -r ${merkle-patricia-forestry} build/packages/aiken-lang-merkle-patricia-forestry
          chmod -R u+w build/packages
        '';

        plutus-blueprint = pkgs.stdenv.mkDerivation {
          pname = "mpf-plutus-blueprint";
          version = "0.0.0";
          src = pkgs.lib.cleanSource ./.;
          nativeBuildInputs = [ pkgs.aiken ];
          buildPhase = ''
            ${aikenPrelude}
            aiken build
          '';
          installPhase = ''
            cp plutus.json $out
          '';
        };

        aiken-check = pkgs.stdenv.mkDerivation {
          pname = "mpf-aiken-check";
          version = "0.0.0";
          src = pkgs.lib.cleanSource ./.;
          nativeBuildInputs = [ pkgs.aiken ];
          buildPhase = ''
            ${aikenPrelude}
            aiken check
          '';
          installPhase = "touch $out";
        };

        # -------------------------------------------------------
        # Haskell build (cage package)
        # -------------------------------------------------------

        project = import ./haskell/nix/project.nix {
          inherit CHaP pkgs;
        };

        components =
          project.project.hsPkgs.cardano-mpfs-cage.components;

        haskellChecks = import ./haskell/nix/checks.nix {
          inherit pkgs components;
          shell = project.project.shell;
          cardanoNode =
            cardano-node.packages.${system}.cardano-node;
        };

        # Aiken-side checks. Exposed so CI can build them via
        # `.#checks.<sys>.<name>` like the Haskell checks, instead
        # of falling back to `nix develop .#aiken --command aiken …`.
        aikenChecks = {
          aiken-build = plutus-blueprint;
          inherit aiken-check;
        };

        haskellApps = import ./haskell/nix/apps.nix {
          inherit pkgs;
          checks = haskellChecks;
        };

        # -------------------------------------------------------
        # Test vectors (from local Haskell package)
        # -------------------------------------------------------

        test-vectors = pkgs.runCommand "cage-vectors.ak" { } ''
          ${pkgs.lib.getExe components.exes.cage-test-vectors} --aiken > $out
        '';

        test-vectors-json = pkgs.runCommand "cage-vectors.json" { } ''
          ${pkgs.lib.getExe components.exes.cage-test-vectors} > $out
        '';

      in
      {
        packages = {
          default = plutus-blueprint;
          inherit plutus-blueprint test-vectors test-vectors-json;
        };

        checks = haskellChecks // aikenChecks;

        apps = haskellApps;

        devShells = {
          aiken = pkgs.mkShell {
            packages = [
              pkgs.aiken
              pkgs.just
              pkgs.lean4
            ];
          };
          default = project.devShells.default;
        };
      }
    );
}
