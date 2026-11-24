{ pkgs, ... }:

{

  # The Tailscale daemon for every machine. common/system.nix imports this
  # module. Run "tailscale up" one time on each machine to join the network.
  services.tailscale.enable = true;

}
