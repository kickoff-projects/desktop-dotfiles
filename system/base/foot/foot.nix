{ pkgs, ... }:

{
  # The foot terminal, for every machine. common/system.nix imports this
  # module. Each host holds its own .config/foot/foot.ini, and that file
  # includes the colours from common/lib/render-foot-colors.nix.
  programs.foot = {
    enable = true;
    };
}
