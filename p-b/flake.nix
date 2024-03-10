{
  nixConfig.allow-import-from-derivation = true;
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    p-a.url = "/home/mangoiv/Devel/repro/p-a";
  };
  outputs = inputs:
    inputs.parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.pre-commit-hooks.flakeModule
      ];

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        pre-commit = {
          check.enable = true;
          settings.hooks = {
            cabal-fmt.enable = true;
            fourmolu.enable = true;
            hlint.enable = true;

            alejandra.enable = true;
            statix.enable = true;
            deadnix.enable = true;
          };
        };
        haskellProjects.default = {
          packages = {
            a.source = "${inputs.p-a}/a";
          };
          settings = {};
          devShell.mkShellArgs.shellHook = config.pre-commit.installationScript;
        };
      };
    };
}
