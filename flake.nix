{
  description = "Project starter";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";
    nixLd.url = "github:Mic92/nix-ld";
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs = { self, nixpkgs, flakeUtils, nixLd, nix2container, ... }@inputs:
    flakeUtils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [ "openssl-1.1.1u" ];
        };
        nix2containerPkgs = nix2container.packages.${system};
        # opensslfix = 
      in {
        devShells.default = pkgs.mkShell { packages = with pkgs; [ nushell ]; };
        packages.tiny = nix2containerPkgs.nix2container.buildImage {
          name = "tiny";
          tag = "latest";
          config = {
            env = [
              "NIX_LD_LIBRARY_PATH=${
                pkgs.lib.makeLibraryPath
                (with pkgs; [ stdenv.cc.cc openssl openssl_1_1 glibc ])
              }:$LD_LIBRARY_PATH"

              "NIX_LD=${
                builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker"
              }"
            ];
          };
          copyToRoot = pkgs.buildEnv {
            name = "root";
            paths = with pkgs; [
              bashInteractive
              # coreutils
              toybox
              glibc
              # musl
              nix-ld
              # (runCommand "profile" { } ''
              #   export LD_LIBRARY_PATH="${

              #   }:$LD_LIBRARY_PATH"
              # '')
              # openssl
              # openssl_1_1
            ];
            pathsToLink = [ "/bin" "/lib64" "/lib" ];
          };
          # config = { entrypoint = [ "${pkgs.hello}/bin/hello" ]; };
        };
      });
}
