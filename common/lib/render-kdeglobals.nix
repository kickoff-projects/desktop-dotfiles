# This makes the kdeglobals color scheme of dolphin from the "dolphin"
# sub-palette in common/palettes.nix.
#
# The KDE platform theme builds the whole Qt palette from this file.
# KHintsSettings::loadPalettes of plasma-integration reads three sources in
# order: the xdg portal, but only inside a flatpak or snap sandbox; then
# kdeglobals, if it holds a [Colors:View] group; then a .colors file. This
# file holds [Colors:View], so the second branch always wins here and no
# .colors file is needed.
#
# KConfig reads a colour that starts with "#" through QColor::fromString, so
# an 8 digit value is #AARRGGBB. That is the byte order of the dolphin
# sub-palette, and these values need no conversion.
{ p }:
''
# Color scheme of dolphin. common/lib/render-kdeglobals.nix makes this file
# from common/palettes.nix.
#
# This file reaches every KDE Frameworks application, and not dolphin alone.
# dolphin and the kio file dialogs are the only ones installed today.
#
# Colors:Selection/BackgroundNormal below is the one key that paints every
# selection in dolphin. KColorScheme::createApplicationPalette copies it to
# both QPalette::Highlight and QPalette::Accent, and the two painters of
# dolphin each read one of that pair:
#  - the file view and the Folders panel, through
#    KItemListWidget::drawItemStyleOption, fill a selected row with Accent at
#    32% alpha, and stroke the ring of the current row with Accent at 100%
#    alpha when that row is also selected or hovered, or at 80% alpha when it
#    is neither. That ring reaches the current row alone, and only while the
#    window is active and the view holds the keyboard focus. A multiple row
#    selection therefore carries one ring, and a focus in the Places sidebar
#    or the filter bar carries none. The ring colour is the fill colour at
#    lighter(110), so the two stay one hue.
#  - the Places sidebar and the kio file dialogs, through
#    Breeze::Style::drawPanelItemViewItemPrimitive, fill a selected row with
#    Highlight as it stands, and so keep the alpha byte of the 8 digit value.
#    The 32% alpha of the dolphin sub-palette therefore reaches this pane
#    alone, because the file view calls setAlphaF with its own numbers
# A black value in that key therefore removes every selection mark against
# the black base. The General/AccentColor key of a Plasma session reaches
# none of these paths, so this group holds no AccentColor key.

[General]
ColorScheme=PastelRainbow

[Colors:Window]
BackgroundNormal=#${p.window}
BackgroundAlternate=#${p.altBase}
ForegroundNormal=#${p.windowText}
ForegroundInactive=#${p.disabledText}
ForegroundActive=#${p.emerald}
ForegroundLink=#${p.link}
ForegroundVisited=#${p.linkVisited}
ForegroundNegative=#${p.negative}
ForegroundNeutral=#${p.neutral}
ForegroundPositive=#${p.positive}
DecorationFocus=#${p.emerald}
DecorationHover=#${p.emerald}

# The file view of dolphin. BackgroundNormal here is the surface that the
# user reads as "the background of dolphin".
[Colors:View]
BackgroundNormal=#${p.base}
BackgroundAlternate=#${p.altBase}
ForegroundNormal=#${p.text}
ForegroundInactive=#${p.disabledText}
ForegroundActive=#${p.emerald}
ForegroundLink=#${p.link}
ForegroundVisited=#${p.linkVisited}
ForegroundNegative=#${p.negative}
ForegroundNeutral=#${p.neutral}
ForegroundPositive=#${p.positive}
DecorationFocus=#${p.emerald}
DecorationHover=#${p.emerald}

[Colors:Button]
BackgroundNormal=#${p.button}
BackgroundAlternate=#${p.mid}
ForegroundNormal=#${p.buttonText}
ForegroundInactive=#${p.disabledText}
ForegroundActive=#${p.emerald}
ForegroundLink=#${p.link}
ForegroundVisited=#${p.linkVisited}
ForegroundNegative=#${p.negative}
ForegroundNeutral=#${p.neutral}
ForegroundPositive=#${p.positive}
DecorationFocus=#${p.emerald}
DecorationHover=#${p.emerald}

# The selection of dolphin. ForegroundNormal reaches the label of a Places
# sidebar row and of a kio file dialog row. A selected label of the file view
# keeps Colors:View/ForegroundNormal, because
# KStandardItemListWidget::normalTextColorRole returns HighlightedText only
# while the row holds the click highlight of a press.
#
# This group holds no BackgroundAlternate key. createApplicationPalette reads
# the alternate background of Colors:Window and Colors:View alone.
[Colors:Selection]
BackgroundNormal=#${p.highlight}
ForegroundNormal=#${p.highlightText}
ForegroundInactive=#${p.disabledText}
ForegroundActive=#${p.highlightText}
ForegroundLink=#${p.link}
ForegroundVisited=#${p.linkVisited}
ForegroundNegative=#${p.negative}
ForegroundNeutral=#${p.neutral}
ForegroundPositive=#${p.positive}
DecorationFocus=#${p.emerald}
DecorationHover=#${p.emerald}

[Colors:Tooltip]
BackgroundNormal=#${p.tooltipBase}
BackgroundAlternate=#${p.mid}
ForegroundNormal=#${p.tooltipText}
ForegroundInactive=#${p.disabledText}
ForegroundActive=#${p.emerald}
ForegroundLink=#${p.link}
ForegroundVisited=#${p.linkVisited}
ForegroundNegative=#${p.negative}
ForegroundNeutral=#${p.neutral}
ForegroundPositive=#${p.positive}
DecorationFocus=#${p.emerald}
DecorationHover=#${p.emerald}

# The toolbar strip above the file view. It takes the window background, so
# the strip matches the rest of the window.
[Colors:Header]
BackgroundNormal=#${p.window}
BackgroundAlternate=#${p.altBase}
ForegroundNormal=#${p.windowText}
ForegroundInactive=#${p.disabledText}
ForegroundActive=#${p.emerald}
ForegroundLink=#${p.link}
ForegroundVisited=#${p.linkVisited}
ForegroundNegative=#${p.negative}
ForegroundNeutral=#${p.neutral}
ForegroundPositive=#${p.positive}
DecorationFocus=#${p.emerald}
DecorationHover=#${p.emerald}

[Colors:Complementary]
BackgroundNormal=#${p.window}
BackgroundAlternate=#${p.altBase}
ForegroundNormal=#${p.windowText}
ForegroundInactive=#${p.disabledText}
ForegroundActive=#${p.emerald}
ForegroundLink=#${p.link}
ForegroundVisited=#${p.linkVisited}
ForegroundNegative=#${p.negative}
ForegroundNeutral=#${p.neutral}
ForegroundPositive=#${p.positive}
DecorationFocus=#${p.emerald}
DecorationHover=#${p.emerald}

[Icons]
Theme=Papirus-Dark
''
