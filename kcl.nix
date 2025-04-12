{
  lib,
  rustPlatform,
  fetchFromGitHub,
  kclvm,
  rustc,
}:
rustPlatform.buildRustPackage rec {
  pname = "kcl-language-server";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "kcl-lang";
    repo = "kcl";
    rev = "v${version}";
    hash = "sha256-qIaDc10NxQKBH7WRzzkQ6bQfkSqsDrFxSwSX+Hf7qS8=";
  };

  sourceRoot = "${src.name}/kclvm";
  useFetchCargoVendor = true;
  cargoHash = "sha256-xRxfhDPgCOvf95q6AoNNtxxBPsqFbDQzWQU3cKalcEg=";

  buildPhaseCargoFlags = [
    "--profile"
    "release"
    "--offline"
  ];

  buildInputs = [
    kclvm
    rustc
  ];

  buildAndTestSubdir = "tools/src/LSP";
  doCheck = false;

  meta = with lib; {
    description = "A high-performance implementation of KCL written in Rust that uses LLVM as the compiler backend";
    homepage = "https://github.com/kcl-lang/kcl";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [lasse16];
    mainProgram = "kcl-language-server";
  };
}
