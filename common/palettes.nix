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
      base0C = "b900b1"; base0D = "00e1cd"; base0E = "8991bb"; base0F = "4d6fff";
      baseAD01 = "5191cc"; baseAD02 = "fb008f"; baseAD03 = "ffd34d";
      baseAD04 = "c31684"; baseAD05 = "7eff46"; baseAD06 = "ffa500";
      baseAD07 = "ffffff"; baseAD08 = "000000"; baseAD09 = "50c878";
      baseAD10 = "ff392e"; baseAD11 = "cb05c3"; baseAD12 = "26ff00";
      baseAD13 = "0c85ff"; baseAD14 = "00ffa5";
      # The original file's "## Additional ##" comment names a different
      # blue (3d85c6) than the one baseAD01 actually declares (5191cc) -
      # a pre-existing mismatch in the hand file, kept verbatim rather than
      # silently fixed.
      commentAD01 = "3d85c6";
    };
    foot = {
      cursor = "00ff00 00ffff"; #34b100
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

  neon_rainbow = {
    kak = {
      title = "neon-rainbow: black/vibrant spectrum (nansus-work)";
      base00 = "000000"; base01 = "0a0a0a"; base02 = "1a1a1a"; base03 = "6a6a7e";
      base04 = "7a6a9c"; base05 = "f2f2f7"; base06 = "ffffff"; base07 = "ffffff";
      # The eight accents now sit in base16's own hue order, so each slot
      # lands on the face set the template was written for: red on
      # variables/errors, orange on constants, yellow on types, green on
      # strings, cyan on builtins, blue on functions, violet/magenta on
      # keywords. Same eight neon values as ../waybar/colors.css, just
      # rotated into the order the set-face body expects.
      base08 = "ff3b30"; base09 = "ff7a00"; base0A = "ffe600"; base0B = "00ff88";
      base0C = "00e5ff"; base0D = "52b4ff"; base0E = "c7a4ff"; base0F = "ff2fb0";
      baseAD01 = "52b4ff"; baseAD02 = "ff2fb0"; baseAD03 = "ffe600";
      baseAD04 = "c7a4ff"; baseAD05 = "00ff88";
      commentAD01 = "52b4ff";
    };
  };
}
