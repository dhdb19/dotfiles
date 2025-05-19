{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      astal,
      ags,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.stdenvNoCC.mkDerivation rec {
        name = "my-shell";
        src = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = path: type: true;
        };
        entry = "app.ts";
        nativeBuildInputs = [
          ags.packages.${system}.default
          pkgs.wrapGAppsHook
          pkgs.gobject-introspection
          pkgs.gtk4
          pkgs.gtk4-layer-shell
        ];

        buildInputs =
          with astal.packages.${system};
          [
            astal3
            astal4
            hyprland
            io
            gjs
            tray
            cava
            auth
            apps
            river
            mpris
            greet
            notifd
            wireplumber
            powerprofiles
            network
            bluetooth
            battery
            pkgs.gtk4
            pkgs.gtk4-layer-shell
            # any other package
          ]
          ++ [
            pkgs.gtk4
            pkgs.gtk4-layer-shell
          ];

        installPhase = ''
          mkdir -p $out/bin
          ags bundle app.ts $out/bin/${name}
        '';
      };
    };
}
