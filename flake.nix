{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    nixpkgs,
    self,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [self.overlays.kcl-language-server];
    };
  in {
    overlays.kcl-language-server = final: prev: {
      kcl-language-server = prev.callPackage ./kcl.nix {};
    };
    devShells.${system} = {
      default = pkgs.mkShellNoCC {
        packages = [pkgs.kcl-language-server];
      };
    };
  };
}
