# KCL language server

Here is a flake and nixpkgs overlay that provides the `kcl-language-server` binary.

Use the devShell from this flake or the overlay directly.

## Usage 
This is a minimal flake template to use this overlay.

```nix

{
  description = "Include the kcl-language-server";

  inputs.kcl-lsp.url = "github:lasse16/kcl-language-server.nix";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = all @ {
    self,
    nixpkgs,
    kcl-lsp,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        kcl-lsp.overlays.kcl-language-server
      ];
    };
  in {
    devShells.x86_64-linux = {
      default = pkgs.mkShellNoCC {
        packages = with pkgs; [kcl-language-server];
      };
    };
  };
}

```
## Background

The KCL instructions ask you to install kcl and then the languager server separately.
There is no package for the language server in Nixpkgs.

The upstream language server is part of the Github repo that contains the KCLVM at [kcl-lang/kclvm](https://github.com/kcl-lang/kclvm).
This package is also in Nixpkgs.
However, installing the `kclvm` package does not make the `kcl-language-server` binary available.

I looked at related packages, like [aldoberro/mynixpkgs](https://github.com/aldoborrero/mynixpkgs/blob/main/pkgs/by-name/kcl-language-server/package.nix) and the [source code for the kclvm package](https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/by-name/kc/kclvm/package.nix).
And these build the Rust package for the `kclvm` tools, so I could just build the LSP project.
The `kcl-language-server` at [kcl-lang/kcl/tree/kclvm/tools/src/LSP](https://github.com/kcl-lang/kcl/tree/main/kclvm/tools/src/LSP) even has a separate `Cargo.toml`, but no `Cargo.lock`.
So, I tried generating the corresponding `Cargo.lock`, but it did not work.
Nixpkgs' `rustPlatform.buildRustPackage` can take a cargoFile attribute, and one can even patch in the missing `Cargo.lock` via the `postPatch` hook, as described in this [rust language guide on Nix](https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md#importing-a-cargolock-file-importing-a-cargolock-file).

While looking at this, I noticed that there are two attributes of the buildRustPackage function, `buildAndTestSubdir`, which allows selecting a subproject to build and, `sourceRoot` to allow selecting the top-level directory.
By setting the top-level directory to `kclvm/` and then building the subdirectory `tools/LSP`.

This works after specifying the necessary hashes.

After double-checking with the `kclvm` package, the underlying package, that builds from the same upstream repository, I noticed that the versions are different.
While seeing this, I also noticed that the difference between `kclvm` and `kcl-language-server` package, is only the `buildAndTestSubdir` property.
Hence, it might be easier and avoid any future version conflicts by simply overriding/inserting that argument into the `kclvm` package, but I dont know the feasibility of this.
So, for now I keep my custom package and you are free to use it too.

> [!NOTE]
> There is also the `kcl` package on Nix pkgs.
> This is a separate git repository at [kcl-lang/cli](https://github.com/kcl-lang/cli).
> It is a Go package that contains the `kcl` cli tool, and not the `kclvm` tool/tooling.
> These are entirely independant, at least for the language server setup.

## References
- <https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md>
- <https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/by-name/kc/kclvm/package.nix>
- <https://discourse.nixos.org/t/help-using-a-nixpkgs-overlay-in-a-flake/46075/6>
- <https://zimbatm.com/notes/1000-instances-of-nixpkgs>
