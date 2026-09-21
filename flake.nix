{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flakever.url = "github:numinit/flakever";
    xnu = {
      url = "github:ProjectCalamari/xnu";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      flakever,
      xnu,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "riscv64-linux"
      ];

      flakeverConfig = flakever.lib.mkFlakever {
        inherit inputs;

        digits = [
          1
          2
          2
        ];
      };

      forAllSystems =
        f:
        genAttrs allSystems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs {
              localSystem = system;
              crossSystem = {
                inherit system;
                useLLVM = true;
                linker = "lld";
              };
              overlays = [ self.overlays.default ];
            };
          }
        );

      treefmtEval = forAllSystems ({ pkgs, ... }: treefmt-nix.lib.evalModule pkgs (import ./treefmt.nix));
    in
    {
      versionTemplate = "413-<lastModifiedDate>-<rev>";

      overlays.default = final: prev: {
        dtrace = final.callPackage ./pkgs/dtrace { flakever = flakeverConfig; };
        ctfconvert = final.callPackage ./pkgs/ctfconvert {
          flakever = flakeverConfig;
          inherit xnu;
        };
      };

      devShells = forAllSystems (
        { pkgs, ... }:
        {
          default = pkgs.dtrace.shell;
          ctfconvert = pkgs.ctfconvert.shell;
        }
      );

      packages = forAllSystems (
        { pkgs, ... }:
        {
          default = pkgs.dtrace;
          inherit (pkgs) ctfconvert;
        }
      );

      formatter = forAllSystems ({ system, ... }: treefmtEval.${system}.config.build.wrapper);

      checks = forAllSystems (
        { system, pkgs, ... }:
        {
          inherit (pkgs) dtrace ctfconvert;
          formatting = treefmtEval.${system}.config.build.check self;
        }
      );
    };
}
