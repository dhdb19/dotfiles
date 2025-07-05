{
  description = "Basic flake for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils.url = "github:numtide/flake-utils";

    quickshell = {
      # add ?ref=<tag> to track a tag
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";

      # THIS IS IMPORTANT
      # Mismatched system dependencies will lead to crashes and other issues.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ags,
      astal,
      utils,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          # system = "x86_64-linux";
          specialArgs = { inherit system inputs; };
          modules = [
            ./configuration.nix
            { nixpkgs.config.allowUnfree = true; }
          ];
        };
      };
      packages.${system}.default = pkgs.stdenvNoCC.mkDerivation rec {
        name = "my-ags-astal-shell";
        src = ./.;

        nativeBuildInputs = [
          ags.packages.${system}.default
          pkgs.wrapGAppsHook
          pkgs.gobject-introspection
        ];

        buildInputs = with astal.packages.${system}; [
          io
          gjs
          # tray
          cava
          auth
          apps
          river
          mpris
          greet
          source
          notifd
          astal3
          astal4
          wireplumber
          powerprofiles
          network
          hyprland
          bluetooth
          battery
          # Add more Astal packages if needed
        ];

        installPhase = ''
          mkdir -p $out/bin
          ags bundle app.ts $out/bin/${name}
        '';
      };

      utils.lib.eachDefaultSystem = (
        system:
        let
          overlay = final: prev: {
            pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
              (python-final: python-prev: {
                python-fabric = prev.callPackage ./default.nix { };
              })
            ];
          };

          pkgs = nixpkgs.legacyPackages.${system}.extend overlay;
        in
        {
          overlays.default = overlay;
          formatter = pkgs.nixfmt-rfc-style;
          packages = {
            default = pkgs.python3Packages.python-fabric;
            run-widget = pkgs.callPackage ./run-widget.nix { };
          };

          devShells = {
            default = pkgs.mkShell {
              name = "fabric-shell";
              packages = with pkgs; [
                ruff
                gtk3
                gtk-layer-shell
                cairo
                gobject-introspection
                libdbusmenu-gtk3
                gdk-pixbuf
                gnome-bluetooth
                cinnamon-desktop
                (python3.withPackages (
                  ps: with ps; [
                    setuptools
                    wheel
                    build
                    click
                    pycairo
                    pygobject3
                    pygobject-stubs
                    loguru
                    psutil
                    python-fabric
                  ]
                ))
              ];
            };
          };
        }
      );

    };
}
