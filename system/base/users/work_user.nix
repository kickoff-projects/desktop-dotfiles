{ pkgs, ... }:

{
  # Separate account for work so the work session can be
  # picked from gdm after closing hyprland, no rebuild
  # needed to swap between leisure and work.

  # Define the primary group for the work user
  users.groups.nansus-work = {};

  # Define the work account. Don't forget to set a password with 'passwd'.
  users.users.nansus-work = {
     isNormalUser = true;
     group = "nansus-work";
     description = "NanSuS-Work";

     # zsh.nix only sets the shell for nansus,
     # so this account needs it spelled out here
     shell = pkgs.zsh;

     extraGroups = [
	"wheel" # Sudo for nansus-work
	"networkmanager" # ability to change internet connections
	"video" # change display settings
	"vboxusers" # ability to use virtual machines
	"libvirtd" # -"-
	"lp"
	"input"
	"audio"
   ];
  };
}
