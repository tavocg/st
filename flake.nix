{
  description = "tavocg's st fork based on st-flexipatch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          st = pkgs.stdenv.mkDerivation {
            pname = "st";
            version = "0.9.3-flexipatch";
            src = self;

            nativeBuildInputs = with pkgs; [
              gnumake
              ncurses
              pkg-config
            ];

            buildInputs = with pkgs; [
              fontconfig
              freetype
              imlib2
              libX11
              libXft
            ];

            makeFlags = [
              "CC=${pkgs.stdenv.cc.targetPrefix}cc"
            ];

            installPhase = ''
              runHook preInstall

              mkdir -p $out/share/terminfo
              TERMINFO=$out/share/terminfo make install \
                PREFIX=$out \
                MANPREFIX=$out/share/man

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Simple terminal emulator for X";
              homepage = "https://github.com/tavocg/st";
              license = licenses.mit;
              mainProgram = "st";
              platforms = platforms.linux;
            };
          };

          default = self.packages.${system}.st;
        });

      apps = forAllSystems (system: {
        st = {
          type = "app";
          program = "${self.packages.${system}.st}/bin/st";
        };

        default = self.apps.${system}.st;
      });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              gnumake
              ncurses
              pkg-config
              fontconfig
              freetype
              imlib2
              libX11
              libXft
            ];
          };
        });
    };
}
