{ ... }:

{
  # Limits for the systemd journal, on every machine. common/system.nix
  # imports this module. The journal keeps 50 MB in 5 files. The rate limit
  # is 500 messages in 30 seconds.
  services.journald.extraConfig = "SystemMaxUse=50M\nSystemMaxFiles=5";
  services.journald.rateLimitBurst = 500;
  services.journald.rateLimitInterval = "30s";
}
