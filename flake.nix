{
  description = "Rails example application";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
    devShell.url    = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, flake-utils, devShell }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
           inherit system;
           config = { allowUnfree = true; };
           overlays = [ devShell.overlay ];
        };

      in with pkgs; {
        devShell = devshell.mkShell {
          imports = [ (devshell.importTOML ./devshell.toml) ];
          packages = [ ];
        };
      });
}
