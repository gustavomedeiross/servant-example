# To automatically load this flake into your shell:
#   1. Set up direnv and nix-direnv.
#   2. Create a file named ".envrc.local", with the contents `use flake`.

{
  description = "Servant Example";

  inputs = {
    nixpkgs = {
      # url = github:NixOS/nixpkgs/nixos-22.05;
      url = github:NixOS/nixpkgs;
    };

    flake-utils = {
      url = github:numtide/flake-utils;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    let
      ghcVersion = "9.4.7";
      ghcName = "ghc${builtins.replaceStrings ["."] [""] ghcVersion}";
      packageName = "servant-example";
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        haskellCompiler = pkgs.haskell.compiler."${ghcName}";
        haskellPackages = pkgs.haskell.packages."${ghcName}";
      in
        {
          packages.default = (haskellPackages.callCabal2nix packageName ./. { });

          pkgs.formatter = nixpkgs.legacyPackages."${system}".nixpkgs-fmt;

          devShells.default = pkgs.mkShell {
            name = "${packageName}-shell";

            # We list top-level packages before packages scoped to the GHC version, so
            # that they appear first in the PATH. Otherwise we might end up with older
            # versions of transitive dependencies (e.g. HLS depending on Ormolu).
            buildInputs = [
              pkgs.cabal-install
              pkgs.hlint
              pkgs.ormolu
              haskellCompiler
              haskellPackages.ghcid
              haskellPackages.haskell-language-server
            ];
          };
        }
    );
}
