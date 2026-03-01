{
  description = "Modular, Reproducible, and Cross-Platform Nix Configs";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nur, ... } @ inputs:
  let
    x86_64-linux = "x86_64-linux";
    username = "mbk";
    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          })
        ]  ++ [ nur.overlays.default ];
      };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { 
        inherit username; 
        inputs = inputs; 
        pkgs-stable = mkPkgs x86_64-linux;
      };
      modules = [ 
        nur.modules.nixos.default
        ./configuration.nix 
      ];
    };
  };
}
