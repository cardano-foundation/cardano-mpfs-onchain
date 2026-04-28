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
    leanBlaster.url = "github:paolino/Lean-blaster/feat/nix-flake";
    lean4Nix.follows = "leanBlaster/lean4-nix";
    leanNixpkgs.follows = "leanBlaster/nixpkgs";
    plutusCoreBlaster = {
      url =
        "github:input-output-hk/PlutusCoreBlaster/17cee18a2058790bca36282d82c19146587fb2d1";
      flake = false;
    };
    cardanoLedgerApiBlaster = {
      url =
        "github:input-output-hk/CardanoLedgerApiBlaster/577e3eb03b5be09354cfdb1c0d0c12e9e16541a0";
      flake = false;
    };
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
      leanBlaster,
      lean4Nix,
      leanNixpkgs,
      plutusCoreBlaster,
      cardanoLedgerApiBlaster,
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

        plutus-blueprint = pkgs.stdenv.mkDerivation {
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

        # -------------------------------------------------------
        # Lean Blaster build graph
        # -------------------------------------------------------

        leanNixPkgs = import leanNixpkgs {
          inherit system;
          overlays = [
            (lean4Nix.readToolchainFile {
              toolchain = leanBlaster.outPath + "/lean-toolchain";
              binary = true;
            })
            (_final: prev: {
              z3 = prev.z3.overrideAttrs {
                version = "4.15.2";
                src = prev.fetchFromGitHub {
                  owner = "Z3Prover";
                  repo = "z3";
                  rev = "z3-4.15.2";
                  hash = "sha256-hUGZdr0VPxZ0mEUpcck1AC0MpyZMjiMw/kK8WX7t0xU=";
                };
              };
            })
          ];
        };

        leanPkgs = leanNixPkgs.lean;

        cleanLeanSource =
          src:
          pkgs.lib.cleanSourceWith {
            inherit src;
            filter =
              path: type:
              let
                baseName = builtins.baseNameOf (toString path);
              in
              pkgs.lib.cleanSourceFilter path type
              && baseName != ".lake"
              && baseName != ".direnv"
              && baseName != "generated"
              && !(pkgs.lib.hasPrefix "result" baseName);
          };

        lean-blaster-package =
          leanBlaster.legacyPackages.${system}.blaster;

        plutus-core-blaster-package = leanPkgs.buildLeanPackage {
          name = "PlutusCore";
          roots = [ "PlutusCore" ];
          src = cleanLeanSource plutusCoreBlaster;
          deps = [ lean-blaster-package ];
        };

        cardano-ledger-api-blaster-package =
          leanPkgs.buildLeanPackage {
            name = "CardanoLedgerApi";
            roots = [ "CardanoLedgerApi" ];
            src = cleanLeanSource cardanoLedgerApiBlaster;
            deps = [
              lean-blaster-package
              plutus-core-blaster-package
            ];
          };

        mpfs-cage-blaster-src =
          pkgs.runCommand "mpfs-cage-blaster-src" { nativeBuildInputs = [ pkgs.jq ]; } ''
            mkdir -p $out
            cp -R ${cleanLeanSource ./lean-blaster}/. $out/
            chmod -R u+w $out
            mkdir -p $out/generated
            extract() {
              local title="$1"
              local output="$2"
              jq -er --arg title "$title" \
                '.validators[] | select(.title == $title) | .compiledCode' \
                ${plutus-blueprint} | tr -d '\n\r[:space:]' > "$output"
            }
            extract "state.state.mint" $out/generated/mpf_state_mint.flat
            extract "state.state.spend" $out/generated/mpf_state_spend.flat
            extract "request.request.spend" $out/generated/mpf_request_spend.flat
            substituteInPlace $out/MpfsCageBlaster/Scripts.lean \
              --replace-fail '"generated/mpf_state_mint.flat"' "\"$out/generated/mpf_state_mint.flat\"" \
              --replace-fail '"generated/mpf_state_spend.flat"' "\"$out/generated/mpf_state_spend.flat\"" \
              --replace-fail '"generated/mpf_request_spend.flat"' "\"$out/generated/mpf_request_spend.flat\""
          '';

        mpfs-cage-blaster-package = leanPkgs.buildLeanPackage {
          name = "MpfsCageBlaster";
          roots = [ "MpfsCageBlaster" ];
          src = mpfs-cage-blaster-src;
          deps = [
            lean-blaster-package
            plutus-core-blaster-package
            cardano-ledger-api-blaster-package
          ];
          overrideBuildModAttrs = _final: prev: {
            buildInputs = (prev.buildInputs or [ ]) ++ [ leanNixPkgs.z3 ];
          };
        };

        lean-blaster = lean-blaster-package.modRoot;
        lean-blaster-z3check = leanBlaster.packages.${system}.z3check;
        plutus-core-blaster = plutus-core-blaster-package.modRoot;
        cardano-ledger-api-blaster =
          cardano-ledger-api-blaster-package.modRoot;
        mpfs-cage-blaster = mpfs-cage-blaster-package.modRoot;

      in
      {
        packages = {
          default = plutus-blueprint;
          inherit
            lean-blaster
            lean-blaster-z3check
            cardano-ledger-api-blaster
            mpfs-cage-blaster
            plutus-blueprint
            plutus-core-blaster
            test-vectors
            test-vectors-json;
        };

        checks = haskellChecks // {
          inherit
            cardano-ledger-api-blaster
            lean-blaster
            mpfs-cage-blaster
            plutus-core-blaster;
          "lean-blaster-smoke-test" =
            leanBlaster.checks.${system}.smoke-test;
          "lean-blaster-tests" = leanBlaster.checks.${system}.tests;
        };

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
