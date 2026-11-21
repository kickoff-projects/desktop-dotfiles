{ pkgs, ... }:

{
  # Feral GameMode. Hyprland's eyecandy toggle is SUPER+G only
  # (~/.config/hypr/scripts/gamemode.sh); this does not hook into it.
  environment.systemPackages = [ pkgs.gamemode ];
  programs.gamemode.enable = true;
}
