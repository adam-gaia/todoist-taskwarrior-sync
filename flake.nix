{
  description = "TODO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ind = {
      url = "github:adam-gaia/ind";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ind, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        poetry-env = pkgs.poetry2nix.mkPoetryEnv {
          projectDir = ./.;
          overrides = pkgs.poetry2nix.defaultPoetryOverrides.extend
            (self: super: {
              taskw = super.taskw.overridePythonAttrs
              (
                old: {
                  buildInputs = (old.buildInputs or [ ]) ++ [ super.poetry ];
                }
              );
            });
        };
        app = pkgs.poetry2nix.mkPoetryApplication {
          projectDir = ./.;
          overrides = pkgs.poetry2nix.defaultPoetryOverrides.extend
            (self: super: {
              taskw = super.taskw.overridePythonAttrs
              (
                old: {
                  buildInputs = (old.buildInputs or [ ]) ++ [ super.poetry ];
                }
              );
            });
        };
      in {
        devShell = poetry-env.env.overrideAttrs (oldAttrs: {
          buildInputs = with pkgs; [
            nixpkgs-fmt
            poetry
            # Poetry's export is now its own plugin.
            # Poetry plugins must be installed via nix, since poetry does not have write permission to the nix store
            #python310Packages.poetry-plugin-export # TODO: how do we base off of python version instead of hardcoded in package name?
            ind.packages.${system}.default
          ];
        });
        packages = {
          default = app; 
        };
      });
}
