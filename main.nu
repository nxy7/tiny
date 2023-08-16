#!/usr/bin/env nu

export def main [] {}

# Build the image and push it to docker hub registry
export def `main build-and-push` [] {
  nix run .#tiny.copyToDockerDaemon --impure
  docker tag tiny:latest nxyt/tiny:latest
  docker push nxyt/tiny:latest
}
