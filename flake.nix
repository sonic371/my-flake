{
  description = "NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dwm-src = {
      url = "github:sonic371/dwm/mybuild";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, dwm-src, ... }: 
    let
      dotfiles = builtins.fetchGit {
        url = "https://github.com/sonic371/dotfiles.git";
        rev = "88ae24141dfc0b8867c14d460a88627295278110";
        lfs = true;
      };
    in {
    nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit dotfiles dwm-src; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit dotfiles; };
          home-manager.users.wade = import ./home.nix;
        }
      ];
    };
  };
}
