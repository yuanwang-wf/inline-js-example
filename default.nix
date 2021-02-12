{ compiler ? "ghc8103" }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };

  gitignore = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];

  myHaskellPackages = pkgs.haskell.packages.${compiler}.override {
    overrides = hself: hsuper: {
      inline-js = (import sources.inline-js { });
      "inline-js-example" =
        hself.callCabal2nix "inline-js-example" (gitignore ./.) { };
    };
  };

  shell = myHaskellPackages.shellFor {
    packages = p: [ p."inline-js-example" ];
    buildInputs = [
      myHaskellPackages.haskell-language-server
      pkgs.haskellPackages.cabal-install
      pkgs.haskellPackages.ghcid
      pkgs.haskellPackages.ormolu
      pkgs.haskellPackages.hlint
      pkgs.niv
      pkgs.nixpkgs-fmt
    ];
    withHoogle = true;
  };

  exe = pkgs.haskell.lib.justStaticExecutables
    (myHaskellPackages."inline-js-example");

  docker = pkgs.dockerTools.buildImage {
    name = "inline-js-example";
    config.Cmd = [ "${exe}/bin/inline-js-example" ];
  };
in {
  inherit shell;
  inherit exe;
  inherit docker;
  inherit myHaskellPackages;
  "inline-js-example" = myHaskellPackages."inline-js-example";
}
