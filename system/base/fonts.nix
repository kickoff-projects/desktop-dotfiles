{pkgs, ...}:

{
  # Add fonts to system
  fonts.packages = with pkgs;
     map (font: font.overrideAttrs {preferLocalBuild = true;}) [
	roboto
	#noto-fonts
	#noto-fonts-cjk-sans
	#noto-fonts-cjk-serif
	#twemoji-color-font
	font-awesome
	#victor-mono
	#iosevka-bin
	# applied as emoji in .dotfiles/system/base/fonts.nix
	# as "Noto Color Emoji"
	noto-fonts-color-emoji

	#nerdfonts
	# applied as serif, sansSerif and monospace in
	# .dotfiles/hosts/Home-Desktop/home.nix,
	# .dotfiles/hosts/Slave/home.nix and
	# .dotfiles/hosts/Work/Home-Laptop-Work/home.nix
	# as "FiraCode Nerd Font", and as the kitty font in
	# .dotfiles/hosts/Work/Home-Laptop-Work/home.nix
	nerd-fonts.fira-code
	nerd-fonts.fira-mono
	nerd-fonts.mononoki

	cascadia-code
	hack-font
	inconsolata
	#source-code-pro
	# applied as serif and sansSerif in
	# .dotfiles/system/base/fonts.nix as "Source Code Pro"
	source-code-pro
        nerd-fonts.hack
        noto-fonts
	corefonts
	
  ];


  # Enable Fira Code as default font
   fonts.fontconfig = {
     enable = true;
     defaultFonts = {
       #monospace = [ "FiraCode Nerd Font" "DroidSansMono Nerd Font" "JetBrainsMono Nerd Font" ];
     
        #serif = [ "Fira Serif Nerd Font" ];
        #sansSerif = [ "Fira Code Nerd Font" ];
        #monospace = [ "Fira Code Nerd Font" ];
        #emoji = [ "Noto Color Emoji" ];

        #sansSerif = [ "Fira Code Nerd Font" ];
        #serif = [ "Fira Serif Nerd Font" ];
        #monospace = [ "inconsolata" ];
        #emoji = [ "Noto Color Emoji" ];

	#SO far the best!!
        serif = [ "Source Code Pro" ];
        sansSerif = [ "Source Code Pro" ];
        monospace = [ "FiraCode Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];

        #serif = [ "Liberation Serif" ];
        #sansSerif = [ "Cantarell" ];
        #monospace = [ "Iosevka Nerd Font Mono" ];
        #emoji = [ "Noto Color Emoji" ];


       };
   };
}
