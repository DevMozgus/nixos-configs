# Entry point: inputs, outputs, nixosConfigurations
{
  description = "NixOS dotfiles — desktop + laptop · Hyprland + Waybar · Material Deep Ocean";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      stylix,
      nixvim,
      nix-vscode-extensions,
      nur,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      mkHost =
        hostname: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = [
            disko.nixosModules.disko
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            ./hosts/${hostname}
            ./hosts/${hostname}/disko-config.nix
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                sharedModules = [ inputs.zen-browser.homeModules.default ];
                extraSpecialArgs = {
                  inherit inputs;
                  isLaptop = (hostname == "laptop");
                };
                users.nicola = import ./home/${hostname}.nix;
              };
            }
            { nixpkgs.overlays = import ./overlays { inherit inputs; }; }
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        desktop = mkHost "desktop" [ ];
        laptop = mkHost "laptop" [ ];
        vm = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = [
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            ./hosts/vm
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                sharedModules = [ inputs.zen-browser.homeModules.default ];
                extraSpecialArgs = {
                  inherit inputs;
                  isLaptop = false;
                };
                users.nicola = import ./home/desktop.nix;
              };
            }
            { nixpkgs.overlays = import ./overlays { inherit inputs; }; }
          ];
        };
      };

      apps.${system}.vm = {
        type = "app";
        program = "${self.nixosConfigurations.vm.config.system.build.vm}/bin/run-vm-vm";
      };
    };
}
