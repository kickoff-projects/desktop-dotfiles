{ pkgs, ... }:

{
  # git and the GitHub CLI, for every machine. common/system.nix imports
  # this module. common/home.nix sets the git identity and the gh
  # credential helper.
  environment.systemPackages = [
    pkgs.git
    pkgs.gh
  ];
}
