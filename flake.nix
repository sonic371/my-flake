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
    st-src = {
      url = "github:sonic371/st-flexipatch/5396e957352d440e343b4e6433b40f1ed7a74b83";
      flake = false;
    };
    dmenu-src = {
      url = "github:sonic371/dmenu/ccae9b52ec20bcb665bdaca53125bb137dcd07fa";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, dwm-src, st-src, dmenu-src, ... }: 
    let
      dotfiles = builtins.fetchGit {
        url = "https://github.com/sonic371/dotfiles.git";
        rev = "a2b9ed726688531170a378d3d16f4f77b8ef6f8e";
        lfs = true;
      };
    in {
    nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit dotfiles dwm-src st-src dmenu-src; };
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
