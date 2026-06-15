{
  description = "Netzob Python 3.13 porting devshell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      python = pkgs.python313;

      runtimeLibs = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        libffi
        openssl
        libpcap
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = [
          python
          pkgs.uv
          pkgs.gcc
          pkgs.gnumake
          pkgs.pkg-config
        ];

        buildInputs = with pkgs; [
          libpcap
          libffi
          openssl
          zlib
        ];

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath runtimeLibs;

        shellHook = ''
          if [ ! -d .venv ]; then
            ${python}/bin/python -m venv .venv
          fi
          source .venv/bin/activate
          export PIP_DISABLE_PIP_VERSION_CHECK=1
          echo "→ $(python --version) in $VIRTUAL_ENV"
        '';
      };
    };
}
