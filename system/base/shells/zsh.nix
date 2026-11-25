{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
     fzf
     lsd
     #zsh
     #oh-my-zsh
     #oh-my-posh

  ];

  programs = {
  # Zsh configuration
      zsh = {
    	enable = true;
	enableCompletion = true;
      ohMyZsh = {
        enable = true;
	plugins = ["git"
		 "gh"
		 "github"
		 "virtualenv" 
		 "direnv"	
		 "fastfile"
		];
	theme = "";
	# good ones been:
	# jonathan, candy, gnzh,
	# strug, xiong-chiamiov,
 	# //kennethreitz\\, ys.
	# frontcube, rkj-repos,
	# kennethreitz  
      	};
      
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      promptInit = ''
	
	# current custom zsh theme, first one that exists wins
	for _zsh_theme in ~/.config/oh-my-zsh/custom/themes/zsh_theme \
			  ~/.dotfiles/system/base/shells/oh-my-zsh/custom/themes/zsh_theme \
			  ~/desktop-dotfiles/system/base/shells/oh-my-zsh/custom/themes/zsh_theme; do
	  [ -f "$_zsh_theme" ] && source "$_zsh_theme" && break
	done
	unset _zsh_theme

	# NixOS aliases. These are functions, and not aliases, because the
	# target must go inside "--flake <path>#<target>". It cannot go after
	# that argument.
	# Both functions accept "desktop" and "nansus@desktop". hms adds the
	# missing user name, and nrs removes it.
	hms() {
	  local t=$1
	  if [[ -z $t ]]; then print -u2 "usage: hms <host|user@host>"; return 1; fi
	  [[ $t == *@* ]] || t=$USER@$t
	  home-manager switch --flake "$HOME/desktop-dotfiles#$t"
	}
	nrs() {
	  local t=$1
	  if [[ -z $t ]]; then print -u2 "usage: nrs <host|user@host>"; return 1; fi
	  sudo nixos-rebuild switch --flake "$HOME/desktop-dotfiles#''${t#*@}"
	}
	alias nfu='nix flake update'
	alias ncg='nix-collect-garbage --delete-older-than'
	alias ncgo='nix-collect-garbage -d'
	alias nd='nix develop'
	alias ns='nix-shell'

	alias c='claude'
        alias cad='freecad'


        # Set-up icons for files/folders in terminal using lsd
        alias ls='lsd'
        alias l='ls -l --total-size'
        alias la='ls -a'
        alias lla='ls -la  --total-size'
        alias lt='ls --tree'

	alias audio='wpctl status'
	alias set-audio='wpctl set-default'

	# Kill aliases
	alias pkd='pkill -i discord'
	alias pks='pkill -i steam'
	alias pk='pkill -i'

	# annoying as hell to have .dotfiles and .dotnet
	# in a same place.
	alias .d='cd ; cd desktop-dotfiles'
        alias .c='cd ; cd desktop-dotfiles/common/.config'
	alias .s='cd ; cd desktop-dotfiles/system/'
	alias .i='cd ; cd school_stuff/Info_for_NixOS'
	alias .htb='cd ; cd HTB_Lab'

	# Annoying as hell to also have swaybg and swayimg
	alias img='swayimg -f' # My dumb ass strugling with this for ten minutes
			       # just to remember this file isn't governed by home.nix :|
					# Remember to rebuild !!
	alias vpn='protonvpn-app'
	alias .f='cd ; cd school_stuff/Fontys_2026/MA-CSE_2026'
	alias .t='cd ; cd school_stuff/Thesis'
	alias .r='cd ; cd rust_projects'

	# And here just to ease my workflow,
	# some aliases to jump to computer configs
	alias .desktop='cd ; cd desktop-dotfiles/hosts/desktop/'
	alias .laptop='cd ; cd desktop-dotfiles/hosts/laptop/'
	alias .server='cd ; cd desktop-dotfiles/hosts/server'

	alias .dc='cd ; cd desktop-dotfiles/hosts/desktop/.config/'
	alias .lc='cd ; cd desktop-dotfiles/hosts/laptop/.config/'
	alias .sc='cd ; cd desktop-dotfiles/hosts/server/.config/'

	# nmap aliases
	alias nmap_open_ports="nmap --open"
	alias nmap_list_interfaces="nmap --iflist"
	alias nmap_slow="sudo nmap -sS -v -T1"
	alias nmap_fin="sudo nmap -sF -v"
	alias nmap_full="sudo nmap -sS -T4 -PE -PP -PS80,443 -PY -g 53 -A -p1-65535 -v"
	alias nmap_check_for_firewall="sudo nmap -sA -p1-65535 -v -T4"
	alias nmap_ping_through_firewall="nmap -PS -PA"
	alias nmap_fast="nmap -F -T5 --version-light --top-ports 300"
	alias nmap_detect_versions="sudo nmap -sV -p1-65535 -O --osscan-guess -T4 -Pn"
	alias nmap_check_for_vulns="nmap --script=vuln"
	alias nmap_full_udp="sudo nmap -sS -sU -T4 -A -v -PE -PS22,25,80 -PA21,23,80,443,3389 "
	alias nmap_traceroute="sudo nmap -sP -PE -PS22,25,80 -PA21,23,80,3389 -PU -PO --traceroute "
	alias nmap_full_with_scripts="sudo nmap -sS -sU -T4 -A -v -PE -PP -PS21,22,23,25,80,113,31339 -PA80,113,443,10042 -PO --script all "
	alias nmap_web_safe_osscan="sudo nmap -p 80,443 -O -v --osscan-guess --fuzzy "
	alias nmap_ping_scan="nmap -n -sP"

	#alias speed='librespeed-cli --no-icmp --server 51'
	alias speed='librespeed-cli'

	# Python / jupyter aliases
	alias lab="uv run --with jupyter jupyter lab"

	# History files
        source <(fzf --zsh);
        HISTFILE=~/.zsh_history;
        HISTSIZE=10000;
        SAVEHIST=10000;
        setopt appendhistory;
        '';
      }; 
   };

  # Set ZSH as default shell for nansus
  users.users.nansus = {   
    shell = pkgs.zsh;
    };
 
  environment.shells = with pkgs; [ zsh ];
}
