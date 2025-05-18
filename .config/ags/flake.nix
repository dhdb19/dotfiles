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
      iconTheme = pkgs.adwaita-icon-theme;
      bundled = ags.lib.bundle rec {
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

        extraPackages =
          with astal.packages.${system};
          [
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
          ]
          ++ [ iconTheme ];
      };

    in
    {
      packages.${system}.default = pkgs.symlinkJoin {
        name = "my-shell-wrapped";
        paths = [ bundled ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/my-shell \
            --set GTK_ICON_THEME ${iconTheme.pname} \
            --set XDG_DATA_DIRS "${iconTheme}/share:${pkgs.gtk4}/share"
        '';
        # installPhase = ''
        #   mkdir -p $out/bin
        #   ags bundle app.ts $out/bin/${name}
        # '';

        # postInstall = ''
        #   wrapPorgram $out/bin/${name} \
        #     --set GTK_ICON_THEME ${iconTheme.pname}\
        #     --set XDG_DATA_DIRS ${iconTheme}/share:${pkgs.gtk4}/share"
        # '';
      };
    };
}
