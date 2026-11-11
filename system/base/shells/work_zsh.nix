{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
     fzf
     lsd

  ];

  programs = {
  # Zsh configuration for the work machines, same
  # shell as zsh.nix but without the leisure aliases
      zsh = {
    	enable = true;
	enableCompletion = true;
      ohMyZsh = {
        enable = true;
	plugins = ["git"
		 "gh"
		 "git-prompt"
		 "virtualenv"
		 "direnv"
		];
	theme = "";
      	};

      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      promptInit = ''
	
	# current custom zsh theme is stored here
	[ -f ~/.dotfiles/system/base/shells/oh-my-zsh/custom/themes/zsh_theme ] && source ~/.dotfiles/system/base/shells/oh-my-zsh/custom/themes/zsh_theme

	# NixOS aliases, these take the host as an argument
	# so they cannot rebuild the wrong machine
	alias hms='home-manager switch --flake .#'
	alias nrs='sudo nixos-rebuild switch --flake .#'
	alias nfu='nix flake update'
	alias ncg='nix-collect-garbage --delete-older-than'
	alias ncgo='nix-collect-garbage -d'
	alias nd='nix develop'
	alias ns='nix-shell'

        # Set-up icons for files/folders in terminal using lsd
        alias ls='lsd'
        alias l='ls -l'
        alias la='ls -a'
        alias lla='ls -la'
        alias lt='ls --tree'

	alias pk='pkill -i'

	# annoying as hell to have .dotfiles and .dotnet
	# in a same place.
	alias .d='cd ; cd .dotfiles'
	alias .s='cd ; cd .dotfiles/system/'

	# History files
        source <(fzf --zsh);
        HISTFILE=~/.zsh_history;
        HISTSIZE=10000;
        SAVEHIST=10000;
        setopt appendhistory;
        '';
      };
   };

  # Set ZSH as default shell for nansus, the work
  # account gets it from users/work_user.nix
  users.users.nansus = {
    shell = pkgs.zsh;
    };

  environment.shells = with pkgs; [ zsh ];
}
