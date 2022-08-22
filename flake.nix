{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";

    satysfi-upstream.url = "github:SnO2WMaN/SATySFi/sno2wman/nix-flake";
    satyxin.url = "path:/home/sno2wman/src/ghq/github.com/SnO2WMaN/satyxin";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    satysfi-upstream,
    satyxin,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            satyxin.overlay
            (final: prev: {
              satysfi = satysfi-upstream.packages.${system}.satysfi;
            })
          ];
        };
      in rec {
        packages = rec {
          satysfi = pkgs.satysfi;
          satysfiDist = pkgs.satyxin.buildSatysfiDist {
            packages = [
              "uline"
              "bibyfi"
              "fss"
            ];
          };
          main = pkgs.satyxin.buildDocument {
            inherit satysfiDist;
            name = "main";
            src = ./src;
            entrypoint = "main.saty";
          };
        };
        defaultPackage = self.packages."${system}".main;

        devShell = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            dprint
            satysfi
            satysfi-formatter
            satysfi-language-server
          ];
        };
      }
    );
}
