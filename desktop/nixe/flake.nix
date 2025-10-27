{
  description = "NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixvim = {
      url = "github:nix-community/nixvim";
      # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim }:

  let
    hostname = "nixe";
    username = "jigglycrumb";
  in
  {
    nixosConfigurations = {
      nixe = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ../../common/modules/nixos-base.nix
          ./configuration.nix
          ./hardware-configuration.nix

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # home-manager.backupFileExtension = "backup";

            home-manager.users.jigglycrumb = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            home-manager.extraSpecialArgs = {
              inherit username;
            };
          }

          nixvim.nixosModules.nixvim
          (import ../../common/modules/nixvim.nix)
        ];
        specialArgs = {
          inherit hostname;
          inherit username;
        };
      };
    };
  };
}
