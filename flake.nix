{
  description = "Project starter";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs = { self, nixpkgs, flakeUtils, nix2container, ... }@inputs:
    flakeUtils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [ "openssl-1.1.1u" ];
        };
        nix2containerPkgs = nix2container.packages.${system};
      in {
        devShells.default = pkgs.mkShell { packages = with pkgs; [ nushell ]; };
        packages.tiny = nix2containerPkgs.nix2container.buildImage {
          name = "tiny";
          tag = "latest";
          copyToRoot = pkgs.buildEnv {
            name = "root";
            paths = with pkgs; [
              bashInteractive
              coreutils
              glibc
              # openssl
              openssl_1_1
            ];
            pathsToLink = [ "/bin" ];
          };
          # config = { entrypoint = [ "${pkgs.hello}/bin/hello" ]; };
        };
      });
}
