{ pkgs, ... }:

{
  # The OpenVPN client for every machine. common/system.nix imports this
  # module. The second line puts update-resolv-conf in /etc/openvpn, and
  # that script sets the DNS servers of the tunnel.
  environment.systemPackages = [ pkgs.openvpn ];
  environment.etc.openvpn.source = "${pkgs.update-resolv-conf}/libexec/openvpn";
}
