{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages.${system} = {
      st = pkgs.symlinkJoin {
        name = "st";
        paths = [
          (pkgs.st.overrideAttrs (old: {
            src = ./.;
          }))
        ];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/st --set FONTCONFIG_FILE ${pkgs.makeFontsConf {
            fontDirectories = [pkgs.nerd-fonts.jetbrains-mono];
          }}
        '';
      };
      default = self.packages.${system}.st;
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        pkg-config
        libX11
        libXft
        libXext
        freetype
        fontconfig
        nerd-fonts.jetbrains-mono
      ];

      shellHook = ''
        export FONTCONFIG_FILE=${pkgs.makeFontsConf {
          fontDirectories = [pkgs.nerd-fonts.jetbrains-mono];
        }}
      '';
    };
  };
}
