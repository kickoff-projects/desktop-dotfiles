# Color data per theme, one sub-palette per surface. The files in common/lib
# make the real config files from this data, and common/home.nix picks the
# theme of each account:
#  - kak: a base16 shape, rendered by render-kak.nix and render-kak-legacy.nix
#  - foot: the 16 terminal slots, rendered by render-foot-colors.nix
#  - rofi: the account.rasi theme, rendered by render-rofi.nix
#  - dolphin: the kdeglobals colour scheme, rendered by render-kdeglobals.nix
#
# The sub-palettes are separate color choices, and not one shared set. The
# rainbow kak scheme is mellow-purple, the rainbow foot scheme is "space
# rainbow", and the rainbow rofi and dolphin schemes are the pastel rainbow
# of common/.claude/themes/pastel-rainbow-theme.json. One shared set changes
# the rendered output of every tool at once.
#
# Every value is a bare hex string without the "#" prefix. A 6 digit value is
# opaque. The dolphin "highlight" key holds the one 8 digit value, and every
# other value is 6 digits. The two 8 digit forms disagree on the position of
# the alpha byte: rofi reads RRGGBBAA, and dolphin reads AARRGGBB because Qt
# reads it that way. An 8 digit value therefore belongs to one sub-palette
# only.
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
    # The two sub-palettes below come from the pastel rainbow claude theme in
    # common/.claude/themes/pastel-rainbow-theme.json. The name of the source
    # key of that theme follows each value.
    #
    # Both backgrounds are solid black.
    #
    # rofi draws its text and its prompt in one emerald. The current row
    # carries no fill, so a 3px emerald outline is the only mark of it. The
    # inverse text inside that outline and the window outline hold the one
    # other colour, promptBorder.
    rofi = {
      background = "000000";      # solid black
      backgroundAlt = "000000";   # the inputbar, also solid black
      foreground = "50c878";      # claude
      selected = "000000";        # black, so the current row carries no fill
      selectedText = "d900ff";    # promptBorder, the inverse text of that row
      emerald = "50c878";         # claude, the outline of the current row
      windowBorder = "d900ff";    # promptBorder, the outline of the window
      prompt = "50c878";          # claude
      # The two states below keep their own colours. A red error and a green
      # success carry meaning that one shared colour removes.
      urgent = "ff5c70";          # error
      active = "a8e0b8";          # success
    };
    dolphin = {
      window = "000000";          # solid black
      base = "000000";            # the file view, also solid black
      altBase = "141019";         # composerSidebarBackground, a faint row stripe
      button = "141019";          # composerSidebarBackground

      mid = "50c878";             # claude
      # One emerald paints every selection of dolphin, because
      # KColorScheme::createApplicationPalette copies this key to both
      # QPalette::Highlight and QPalette::Accent. One shared key means the
      # fill and the ring of the file view cannot hold separate colours, so
      # the rofi shape of a clear row inside an emerald outline is out of
      # reach here.
      #
      # This value is 8 digits, so it carries the alpha byte 52, which is
      # 32%. The two painters read that byte differently:
      #  - the file view and the Folders panel discard it. Their
      #    KItemListWidget::drawItemStyleOption calls setAlphaF with its own
      #    numbers: 32% for a selected row, 40% for a selected and hovered
      #    row, 100% for the ring of the current row and for a press
      #  - the Places sidebar and the kio file dialogs keep it.
      #    Breeze::Helper::renderSelection fills with the brush as it stands
      # The selected rows of both panes therefore hold one 32% emerald wash,
      # and the black base reads through each of them. A lower alpha byte
      # here makes the sidebar wash fainter, and leaves the file view as it
      # is.
      highlight = "5250c878";     # claude at 32% alpha
      # The DecorationFocus and DecorationHover keys of every colour group,
      # which Breeze reads through KStatefulBrush as the focus outline and
      # the hover outline of its own widgets: buttons, line edits, the filter
      # bar, the Places sidebar. The file view draws its own hover wash from
      # "text" below at 6% alpha, and reaches no decoration key.
      emerald = "50c878";         # claude, the focus and hover outlines
      tooltipBase = "141019";     # composerSidebarBackground
      # The general text of dolphin: the file view labels, the Places sidebar
      # labels, the toolbar, the menus, the breadcrumb and the tooltips. One
      # emerald holds all of them, and it matches the selection fill and the
      # outlines above. It reaches about 8 contrast against the black base.
      #
      # This emerald is also the label of a selected file view row, because
      # KStandardItemListWidget::normalTextColorRole returns QPalette::Text
      # there unless the row holds the click highlight of a press. A selected
      # file view row therefore reads as emerald text on the 32% alpha
      # emerald wash, and the wash alone marks the selection.
      #
      # The hover wash of the file view is this same colour at 6% alpha, so
      # hover and selection hold one hue at two strengths.
      text = "50c878";            # claude
      windowText = "50c878";      # claude
      buttonText = "50c878";      # claude
      # ForegroundInactive of every colour group, which is the disabled and
      # inactive cue. It stays grey, so a disabled label reads as disabled.
      disabledText = "9a93ad";    # inactive
      tooltipText = "50c878";     # claude
      # The label of a selected Places sidebar row and of a selected kio file
      # dialog row. This is the same value that the rofi sub-palette above
      # uses for its own inverse text. A selected label of the file view
      # keeps "text" above, because dolphin reads this colour there only
      # while a row holds the click highlight of a press.
      highlightText = "d900ff";   # promptBorder
      link = "1bb2fd";            # suggestion
      linkVisited = "661bfd";     # permission
      negative = "ff5c70";        # error
      neutral = "ffd23f";         # warning
      positive = "a8e0b8";        # success
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
