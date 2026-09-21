{
  lib,
  stdenv,
  flakever,
  mkShell,
  xnu,
  pkg-config,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ctfconvert";
  inherit (flakever) version;

  src = lib.cleanSource ../../.;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    zlib
  ];

  makeFlags = [
    "-C tools/ctfconvert"
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
    "PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"
    "XNU_SOURCE=${xnu}"
  ];

  installFlags = [ "PREFIX=$(out)" ];

  passthru.shell = mkShell {
    name = "ctfconvert-dev-shell";
    shellHook = ''
      export CC="${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
      export CXX="${stdenv.cc}/bin/${stdenv.cc.targetPrefix}c++"
      export PKG_CONFIG="${stdenv.cc.targetPrefix}pkg-config"
      export XNU_SOURCE="${xnu}"
    '';
    packages = [
      pkg-config
      zlib
    ];
  };
})
