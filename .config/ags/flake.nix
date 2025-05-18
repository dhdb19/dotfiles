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
      packages.${system}.default = ags.lib.bundle rec {
        inherit pkgs;
        name = "my-shell";
        src = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = path: type: true;
        };
        entry = "app.ts";
        gtk4 = false;

        # nativeBuildInputs = [
        #   ags.packages.${system}.default
        #   pkgs.wrapGAppsHook
        #   pkgs.gobject-introspection
        # ];

        extraPackages = with astal.packages.${system}; [
          astal3
          io
          gjs
          cava
          auth
          tray
          apps
          river
          mpris
          greet
          notifd
          astal4
          wireplumber
          powerprofiles
          network
          hyprland
          bluetooth
          battery
          # any other package
        ];

        # installPhase = ''
        #   mkdir -p $out/bin
        #   ags bundle app.ts $out/bin/${name}
        # '';
      };
    };
}
