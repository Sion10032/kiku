{
  description = "devShell for kiku";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: let
    # system should match the system you are running on
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs { inherit system; };
    in
      pkgs.mkShellNoCC {
        packages = with pkgs; [
          sqlite
          bun
          nodejs-slim_24
        ];

        # 等价于你的：
        # LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
      };
  };
}
