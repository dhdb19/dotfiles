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
      gtk4-wayland = pkgs.gtk4.override {
        waylandSupport = true;
        x11Support = true;
      };
      # agsPkg = ags.packages.${system}.default.override {
      #   gtk4 = gtk4-wayland;
      #   libgtk-layer-shell = pkgs.gtk4-layer-shell;
      # };
      iconTheme = pkgs.adwaita-icon-theme;
      baseBundle = ags.lib.bundle rec {
        inherit pkgs;
        name = "my-shell";
        src = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = path: type: true;
        };
        entry = "app.ts";
        # gtk4 = true;

        # nativeBuildInputs = [
        #   ags.packages.${system}.default
        #   pkgs.wrapGAppsHook
        #   pkgs.gobject-introspection
        # ];
        # extraWrapperArgs = [
        #   "--prefix"
        #   "GDK_BACKEND"
        #   ":"
        #   "wayland"
        #   "--prefix"
        #   "GI_TYPELIB_PATH"
        #   ":"
        #   "${pkgs.gtk4-layer-shell}/lib/girepository-1.0"
        #   "--prefix"
        #   "LD_LIBRARY_PATH"
        #   ":"
        #   "${pkgs.gtk4-layer-shell}/lib"
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
            pkgs.gtk4-layer-shell
            # pkgs.gtk-layer-shell
            # any other package
          ]
          ++ [ iconTheme ];
      };

      wrapped =
        pkgs.runCommand "my-shell"
          {
            buildInputs = [ pkgs.makeWrapper ];
          }
          ''
            mkdir -p $out/bin
            cp ${baseBundle}/bin/my-shell $out/bin/
            wrapProgram $out/bin/my-shell \
            --set GTK_ICON_THEME ${iconTheme.pname} \
            --set XDG_DATA_DIRS "${iconTheme}/share:${pkgs.gtk4}/share"\
            --prefix GI_TYPELIB_PATH : ${pkgs.gtk4-layer-shell}/lib/girepository-1.0 \
            --prefix LD_LIBRARY_PATH : ${pkgs.gtk4-layer-shell}/lib
            cp -r ${baseBundle}/share $out/
          '';

    in
    {
      packages.${system}.default = wrapped;
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ baseBundle ];
        packages = [
          pkgs.gjs
          pkgs.gtk4
          pkgs.gtk4-layer-shell
          pkgs.libadwaita
        ];

        shellHook = ''
          export GDK_BACKEND=wayland
          export GI_TYPELIB_PATH=${pkgs.gtk4-layer-shell}/lib/girepository-1.0${
            pkgs.lib.optionalString (pkgs ? libadwaita) ":${pkgs.libadwaita}/lib/girepository-1.0"
          }
          export LD_LIBRARY_PATH=${pkgs.gtk4-layer-shell}/lib:$LD_LIBRARY_PATH
          export XDG_DATA_DIRS="${iconTheme}/share:${pkgs.gtk4}/share:$XDG_DATA_DIRS"
          echo "🔧 AGS dev shell ready. Environment set for Gtk4 layer shell."
        '';
        # packages = [
        #   agsPkg
        #   pkgs.gjs
        #   pkgs.gtk4-layer-shell
        # ];
      };
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
}
