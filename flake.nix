{
  description = "TODO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        poetry-env = pkgs.poetry2nix.mkPoetryEnv { projectDir = ./.; };
      in
      {
        devShell = poetry-env.env.overrideAttrs (oldAttrs: {
          buildInputs = with pkgs;
            [
              nixpkgs-fmt
              entr
              fd
              poetry
              # Poetry's export is now its own plugin.
              # Poetry plugins must be installed via nix, since poetry does not have write permission to the nix store
              #python310Packages.poetry-plugin-export # TODO: how do we base off of python version instead of hardcoded in package name?
            ];
        });
        packages =
          {
            default = pkgs.poetry2nix.mkPoetryApplication {
              projectDir = ./.;
            };
          };

      });
}
