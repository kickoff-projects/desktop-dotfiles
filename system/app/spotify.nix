{ pkgs, ... }:

{
  # Spotify for every account. common/home.nix imports this module.
  home.packages = [ pkgs.spotify ];
}
