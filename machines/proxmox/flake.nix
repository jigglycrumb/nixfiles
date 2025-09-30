{
  description = "NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      anker = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./vm-base.nix
          ./anker/configuration.nix
          ./anker/hardware-configuration.nix
        ];
      };

      driftwood = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./vm-base.nix
          ./driftwood/configuration.nix
          ./driftwood/hardware-configuration.nix
        ];
      };

      hafen = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./vm-base.nix
          ./hafen/configuration.nix
          ./hafen/hardware-configuration.nix
        ];
      };

      kraken = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./vm-base.nix
          ./kraken/configuration.nix
          ./kraken/hardware-configuration.nix
        ];
      };

      nautilus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./vm-base.nix
          ./nautilus/configuration.nix
          ./nautilus/hardware-configuration.nix
        ];
      };

      siren = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./vm-base.nix
          ./siren/configuration.nix
          ./siren/hardware-configuration.nix
        ];
      };
    };
  };
}
