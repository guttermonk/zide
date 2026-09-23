{
  description = "Zellij, a file picker and your $EDITOR arranged as an IDE layout";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # Consumers who want zide configured (custom layouts, a picker config of
      # their own) should use .override rather than copying files over the
      # result; see the argument comments in package.nix.
      packages = forAllSystems (pkgs: rec {
        zide = pkgs.callPackage ./package.nix { };
        default = zide;
      });

      overlays.default = final: _prev: {
        zide = final.callPackage ./package.nix { };
      };

      apps = forAllSystems (pkgs: rec {
        zide = {
          type = "app";
          program = nixpkgs.lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.zide;
        };
        default = zide;
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
