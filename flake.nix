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
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      haskellNix,
      iohkNix,
      CHaP,
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

        checks = haskellChecks;

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
