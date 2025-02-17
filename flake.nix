{
  description = "Antoine's Nix/NixOS config";

  nixConfig = {
    extra-experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org/"
    ];

    # nix community's cache server
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # A flake is basically a list of inputs/outputs in which inputs are built and sent as arguments to outputs
  inputs = {
    # Official NixOS packages URL
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Home manager for home-scoped config
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    # Spicetify flake for Nix integration
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Hyprland utils
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # XP-bot on Rattlesnake
    xp-bot = {
      url = "github:Morantoine/XP_Bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    umu= {
      url = "git+https://github.com/Open-Wine-Components/umu-launcher/?dir=packaging\/nix&submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Sops-Nix for secrets managing
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Catppuccin for obvious reasons
    catppuccin = {
      url = "github:catppuccin/nix";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , hyprland
    , spicetify-nix
    , home-manager
    , hyprland-contrib
    , xp-bot
    , sops-nix
    , catppuccin
    , ...
    }: {
      nixosConfigurations = {
        # My hostname, don't forget to change it !
        balrog = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          # Load configuration
          modules = [

            ./overlays
            ./hosts/balrog
            catppuccin.nixosModules.catppuccin
            sops-nix.nixosModules.sops

            # Load Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Change the username !
              home-manager.extraSpecialArgs = { inherit inputs; };
              # home-manager.extraSpecialArgs = inputs;
              home-manager.users.antoine = import ./hosts/balrog/balrog_home.nix;
            }
          ];
        };
        rattlesnake = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          # Load configuration
          modules = [

            ./hosts/rattlesnake
            sops-nix.nixosModules.sops

            # Load Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Change the username !
              home-manager.extraSpecialArgs = { inherit inputs; };
              # home-manager.extraSpecialArgs = inputs;
              home-manager.users.antoine = import ./hosts/rattlesnake/rattlesnake_home.nix;
            }
          ];
        };
      };
    };
}
