# Color data per theme for the two surfaces that use a pure 16-slot
# palette: kakoune, which already has a base16 shape, and foot.
# common/lib/render-kak.nix and common/lib/render-foot-colors.nix make the
# real files from this data. common/home.nix picks the theme of each
# account.
#
# Each theme holds two separate color choices, one for kak and one for foot.
# They are not one shared set. The rainbow kak scheme is mellow-purple and
# the rainbow foot scheme is "space rainbow". Each one belongs to its own
# tool. One shared set changes the rendered output of both.
{
  rainbow = {
    kak = {
      title = "base16-mellow-purple "; # trailing space is intentional
      base00 = "1e0528"; base01 = "1a092d"; base02 = "331354"; base03 = "320f55";
      base04 = "564285"; base05 = "ffeeff"; base06 = "ffeeff"; base07 = "f8c0ff";
      base08 = "00d9e9"; base09 = "aa00a3"; base0A = "955ae7"; base0B = "05cb0d";
      base0C = "b900b1"; base0D = "00e1cd"; base0E = "8991bb"; base0F = "4d6fff";
      baseAD01 = "5191cc"; baseAD02 = "fb008f"; baseAD03 = "ffd34d";
      baseAD04 = "c31684"; baseAD05 = "7eff46"; baseAD06 = "ffa500";
      baseAD07 = "ffffff"; baseAD08 = "000000"; baseAD09 = "50c878";
      baseAD10 = "ff4a2e"; baseAD11 = "cb05c3"; baseAD12 = "26ff00";
      baseAD13 = "0c85ff"; baseAD14 = "00ffa5"; baseAD15 = "f800ee";
      baseAD16 = "e91000";
      # The "## Additional ##" comment of the hand written file names the
      # blue 3d85c6. baseAD01 declares the blue 5191cc. The two values do
      # not agree. This file keeps both values without a change.
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
      # The 8 accents follow the hue order of base16. Each slot therefore
      # reaches the face set of the template:
      #  - red on variables and errors
      #  - orange on constants
      #  - yellow on types
      #  - green on strings
      #  - cyan on builtins
      #  - blue on functions
      #  - violet and magenta on keywords
      # These are the same 8 neon values as in ../waybar/colors.css. They
      # follow the order that the set-face body needs.
      base08 = "ff3b30"; base09 = "ff7a00"; base0A = "ffe600"; base0B = "00ff88";
      base0C = "00e5ff"; base0D = "52b4ff"; base0E = "c7a4ff"; base0F = "ff2fb0";
      baseAD01 = "52b4ff"; baseAD02 = "ff2fb0"; baseAD03 = "ffe600";
      baseAD04 = "c7a4ff"; baseAD05 = "00ff88";
      commentAD01 = "52b4ff";
    };
  };
}
