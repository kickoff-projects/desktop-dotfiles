{
  # might be too much to describe what happens in description
  description = "flake for my computers and servers";

  # pkgs imported from git and such
  inputs = {
    # nix pkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Home-mnanger and it is set to follow same nixpkgs version
    # as nixpkgs.url has been set to.
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Most of my machines can be found on nixos-hardware
    # repo so I'm using them there. if you are more interested,
    # Server is custom built computer which doesn't have
    # configuration in nixos-hardware, check:
    # .dotfiles/system/hardware/nividia_proprietary.nix or
    # https://nixos.wiki/wiki/Nvidia for more info
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # For easier /nix/store workflow
    #nix-index-database.url = "github:nix-community/nix-index-database";
    #nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # prettier cursor, change with your
    # own preference as they can be found
    # in myriad forms in git repos
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };

    # Import hyprland even tough I know in my heart that
    # this doens't do shit
    # in my configuration because I have been so lazy to
    # not change hyprland.nix file in system/base/ :(
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VSCode server for running e.g jupyter server for
    # machine learning purposes
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # Zen browser
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Here the machine output that is result of
  # inputs given above and a modular set of .nix files
  # other pkgs, tadaa!
  outputs = {

      self,
      nixpkgs,
      hyprland,
      home-manager,
      nixos-hardware,
      vscode-server,
      rose-pine-hyprcursor,
      zen-browser

      }@inputs:

    # "let in" couple of more used blocks of informations
    # like system versions as $system and so on to
    # nixosConfiguration and homeConfiguration.
    let

      # ---- SYSTEM SETTINGS ----
        system = "x86_64-linux";
        lib = nixpkgs.lib;
        pkgs = import nixpkgs {
	     inherit system;
           # Allow unfree because I happen
	   # to still use software that is not
	   # all open-source, my bad!
  	   config.allowUnfree = true;
	};

      # The networking.hostName value of each host configuration.nix. This
      # set repeats those values, because Nix builds home-manager on its own
      # through homeFor below. That build cannot read the matching
      # nixosConfiguration.
      # common/home.nix tests these names against the real /etc/hostname. A
      # switch to the wrong "<user>@<host>" target then fails with a
      # message. Without the test, it replaces the .config files of that
      # machine with the files of another host.
      hostNames = {
        desktop = "NanSuS-Desktop";
        laptop = "NanSuS-Laptop";
        server = "NixOS-Server";
      };

      # This helper builds "nansus@<host>" and "nansus-work@<host>". It
      # joins common/home.nix, users/<user>/home.nix and the .config files
      # of that host.
      # host is the directory name under hosts/. It is also the
      # nixosConfigurations attribute. See hosts/<host>/configuration.nix.
      homeFor = user: host:
        let
          hostDir = ./hosts + "/${host}";
          themeFile = hostDir + "/theme.nix";
        in
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit hostDir inputs;
            expectedHostName = hostNames.${host};
          };
          modules = [
            ./common/home.nix
            ./users/${user}/home.nix
          ] ++ lib.optional (builtins.pathExists themeFile) themeFile ++ [
            {
              home.username = user;
              home.homeDirectory = "/home/${user}";
            }
          ];
        };
    in {

      # Nixos configuration set for desktop, laptop and server.
      # Anything else is a demo until further declared
      nixosConfigurations = {
	# Leisure configuration for desktop
        desktop = lib.nixosSystem {
          inherit system;
          modules = [
             "${self}/hosts/desktop/configuration.nix"

	     # This profile holds the nvidia setup for this host. It imports
	     # common/gpu/nvidia, which sets videoDrivers to ["nvidia"]. It
	     # also sets hardware.nvidia.open to true. That value is correct
	     # for the RTX 3070.
             nixos-hardware.nixosModules.lenovo-legion-t526amr5
	     #nix-index-database.nixosModules.default
          ];
          specialArgs = {
            inherit inputs;
          };
        };

	# Leisure configuration for home Laptop
        laptop = lib.nixosSystem {
          inherit system;
          modules = [
            "${self}/hosts/laptop/configuration.nix"
	    nixos-hardware.nixosModules.lenovo-legion-16ithg6
	    #nix-index-database.nixosModules.default
          ];
          specialArgs = {
            inherit self inputs;
          };
        };

	# Headless ML / dev box, runs sway rather than hyprland
	# (see hosts/server/configuration.nix)
        server = lib.nixosSystem {
          inherit system;
          modules = [
            "${self}/hosts/server/configuration.nix"
	    #nix-index-database.nixosModules.default

	    # remember to run this on host machine:
	    # systemctl --user enable auto-fix-vscode-server.service
            vscode-server.nixosModules.default
            ({ config, pkgs, ... }: {
               services.vscode-server.enable = true;
	    })
          ];
          specialArgs = {
            inherit inputs;
          };
        };

	# live-usb boot
	live-usb = lib.nixosSystem {
	   inherit system;
	   modules = [
	      "${self}/hosts/live-usb/configuration.nix"
	      "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
	   ];
	   specialArgs = {
	      inherit inputs;
	   };
	};

      };

      # Home configuration for desktop, laptop and server.
      # nansus-work only exists on the two leisure hosts.
      homeConfigurations = {
        "nansus@desktop" = homeFor "nansus" "desktop";
        "nansus-work@desktop" = homeFor "nansus-work" "desktop";

        "nansus@laptop" = homeFor "nansus" "laptop";
        "nansus-work@laptop" = homeFor "nansus-work" "laptop";

        "nansus@server" = homeFor "nansus" "server";
      };
    };
}
