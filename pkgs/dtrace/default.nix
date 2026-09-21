{
  lib,
  stdenv,
  buildPackages,
  flakever,
  mkShell,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dtrace";
  inherit (flakever) version;

  src = lib.cleanSource ../../.;

  passthru.shell = mkShell {
    name = "dtrace-dev-shell";
    shellHook = ''
      export CC="${stdenv.cc.cc}/bin/clang"
      export CXX="${stdenv.cc.cc}/bin/clang++"
      export HOST_CC=cc
      export HOST_CXX=c++
    '';
    packages = [
    ];
  };
})
