{ ... }:

{

# This is a root owned copy, and not ~/.mitmproxy. Any program that runs as
# the user can change the copy in the home directory. The whole system
# then trusts that copy.
# Install this file one time with this command:
# sudo install -D -m444 ~/.mitmproxy/mitmproxy-ca-cert.pem /etc/mitmproxy/mitmproxy-ca-cert.pem
security.pki.certificateFiles = [
  "/etc/mitmproxy/mitmproxy-ca-cert.pem"
]; 
	
}
