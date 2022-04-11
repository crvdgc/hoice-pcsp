# Template from https://github.com/jonascarpay/template-haskell
{
  description = "hoice-pcsp";
  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlay = self: _: {
          hsPkgs =
            self.haskell-nix.project' rec {
              src = ./.;
              compiler-nix-name = "ghc8107";
              shell = {
                tools = {
                  cabal = "latest";
                  # ghcid = "latest";
                  haskell-language-server = "latest";
                  # hlint = "latest";
                  # See https://github.com/input-output-hk/haskell.nix/issues/1337
                  ormolu = {
                    version = "latest";
                    modules = [ ({ lib, ... }: { options.nonReinstallablePkgs = lib.mkOption { apply = lib.remove "Cabal"; }; }) ];
                  };
                };
              };
            };
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            haskellNix.overlay
            overlay
          ];
        };
        flake = pkgs.hsPkgs.flake { };
      in
      flake // { defaultPackage = flake.packages."hoice-pcsp:exe:hoice-pcsp"; }
    );
}
