{
  description = "Basic flake for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }@inputs:
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
          specialArgs = { inherit system; };
          modules = [
            ./configuration.nix
            { nixpkgs.config.allowUnfree = true; }
          ];
        };
      };
    };
}
