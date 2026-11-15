# Per-theme color data for the surfaces that are pure 16-slot palettes:
# kakoune (base16-shaped already) and foot. Rendered into real files by
# common/lib/render-kak.nix and common/lib/render-foot-colors.nix - see
# common/home.nix and hosts/Server/theme.nix for where each theme is picked.
#
# kak and foot are deliberately two separate color choices per theme, not
# one shared set: the existing rainbow kak scheme (mellow-purple) and the
# existing rainbow foot scheme ("space rainbow") were authored independently
# for their own tool, and unifying them would change what currently
# renders. These values are copied verbatim from the files they replace.
{
  rainbow = {
    kak = {
      title = "base16-mellow-purple "; # trailing space matches the original file
      base00 = "1e0528"; base01 = "1a092d"; base02 = "331354"; base03 = "320f55";
      base04 = "917EBF"; base05 = "ffeeff"; base06 = "ffeeff"; base07 = "f8c0ff";
      base08 = "00d9e9"; base09 = "aa00a3"; base0A = "955ae7"; base0B = "05cb0d";
      base0C = "b900b1"; base0D = "550068"; base0E = "8991bb"; base0F = "4d6fff";
      baseAD01 = "5191cc"; baseAD02 = "fb008f"; baseAD03 = "ffd34d";
      baseAD04 = "c31684"; baseAD05 = "7eff46";
      # The original file's "## Additional ##" comment names a different
      # blue (3d85c6) than the one baseAD01 actually declares (5191cc) -
      # a pre-existing mismatch in the hand file, kept verbatim rather than
      # silently fixed.
      commentAD01 = "3d85c6";
    };
    foot = {
      cursor = "fb008f 3d85c6";
      background = "0a0a20"; foreground = "ffffff";
      regular0 = "d32f2f"; regular1 = "ff4081"; regular2 = "4caf50"; regular3 = "ffeb3b";
      regular4 = "2196f3"; regular5 = "9c27b0"; regular6 = "00bcd4"; regular7 = "607d8b";
      bright0 = "ff5722"; bright1 = "ff9800"; bright2 = "00e676"; bright3 = "cddc39";
      bright4 = "009688"; bright5 = "673ab7"; bright6 = "3f51b5"; bright7 = "ffffff";
    };
  };

  red = {
    kak = {
      title = "red: black and red (derived from purple_best / matrix)";
      base00 = "000000"; base01 = "0a0202"; base02 = "3d0a0a"; base03 = "5a0f0f";
      base04 = "8f1111"; base05 = "ff2b2b"; base06 = "ff2b2b"; base07 = "ffc8c8";
      base08 = "ff3b14"; base09 = "cc0000"; base0A = "ff7d7d"; base0B = "ff4d4d";
      base0C = "b11a1a"; base0D = "6b0f0f"; base0E = "ff6666"; base0F = "a81a1a";
      baseAD01 = "ff2b2b"; baseAD02 = "5a0f0f"; baseAD03 = "ff3b14";
      baseAD04 = "cc0000"; baseAD05 = "ff7e46";
      # Here the comment matches baseAD01 exactly - no mismatch for this theme.
      commentAD01 = "ff2b2b";
    };
    foot = {
      cursor = "000000 ff2b2b";
      background = "000000"; foreground = "ffffff";
      regular0 = "d32f2f"; regular1 = "cc0000"; regular2 = "4caf50"; regular3 = "ffeb3b";
      regular4 = "2196f3"; regular5 = "9c27b0"; regular6 = "00bcd4"; regular7 = "bf8f8f";
      bright0 = "ff5722"; bright1 = "ff2b2b"; bright2 = "00e676"; bright3 = "cddc39";
      bright4 = "009688"; bright5 = "673ab7"; bright6 = "3f51b5"; bright7 = "ffffff";
    };
  };
}
