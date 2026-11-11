{ ... }:

{

# Root owned copy, not ~/.mitmproxy. Anything running as
# the user could rewrite the one in home and the whole
# system would trust it. Put it there once with:
# sudo install -D -m444 ~/.mitmproxy/mitmproxy-ca-cert.pem /etc/mitmproxy/mitmproxy-ca-cert.pem
security.pki.certificateFiles = [
  "/etc/mitmproxy/mitmproxy-ca-cert.pem"
]; 
	
}
