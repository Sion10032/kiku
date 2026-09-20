{
  description = "devShell for kiku";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: let
    # nixpkgs 26.11 起已移除 x86_64-darwin，故不再列出
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (
        system: f (import nixpkgs { inherit system; })
      );
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          sqlite
          bun
          nodejs-slim_24
          ffmpeg
        ];
      };
    });
  };
}
