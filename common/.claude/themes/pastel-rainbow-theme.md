# pastel rainbow — decision log

Companion to `pastel-rainbow-theme.json`. JSON takes no comments, so the
rationale for every slot lives here instead — same convention as the long
header and per-slot notes in `users/nansus/.config/waybar/colors.css`.

Every surface was chosen one slot at a time, in order of how often it is on
screen. Each entry names the options that lost and what claimed the hue, so
a later edit can tell a deliberate choice from an arbitrary one.

# The two rules everything obeys

Pastels only ever land in foreground accents, where they sit on the
terminal's near-black and clear roughly 8:1 against it. Every surface stays
at or below about `#2b2b33` luminance, so `#ffffff` clears 10:1 on it. The
classifier for which slot is which came from the binary's own light-theme
defaults: a slot that is near-white in the light theme is a surface with
text drawn on it, and a slot that is saturated is a foreground accent.

Five slots now break the surface half of that rule on purpose:
`selectionBg #661bfd`, `permission #661bfd`, `clawd_background #ff00ff`,
`diffAdded #77dd77` and `diffRemoved #ff6961` are saturated or pale, not
dark. The entries below say so where it applies.

# Text

`text` is `#574785`, a deep violet, and `inverseText` is `#ffffff`. Message
bodies and diff content draw in that violet, which clears about 2.6:1 on the
account's pure-black terminal. That is below the 4.5:1 body-text threshold:
the slot is a dim prose color by choice, not a readable one. Kakoune's
`base05` carries the same value for this account, so prose matches between
the two. Foot's `foreground` stays `#9574f6`, the lighter violet, so terminal
output outside kakoune reads brighter than claude-code's prose. The named semantic slots keep their pastel hue instead of
collapsing to one color, because they are UI accents rather than prose —
losing their color would cost the scannability of labels, subagent names and
the spinner.

# Surfaces, in the order they were decided

**1. `composerSidebarBackground` — `#141019`, faint violet.** The strip
beside the prompt, the most-seen surface claude draws. Violet was unclaimed,
sits closest to the waybar true-black base while still reading as tinted,
and white clears about 17:1 on it. Indigo lost because it was the natural
pick for the next slot; teal lost because `background` already spends a
deep teal; untinted `#121212` lost because it would leave the most-seen
surface with no identity.

**2. `userMessageBackground` — `#5d009b`, deep purple.** The block behind
everything the user types. Originally `#1b1830` indigo, but that cleared
17.2:1 against white — far darker than the binary's own dark-theme default
for this slot, `rgb(55,55,55)` = `#373737` at 11.9:1 — so it read as too
dark. It now sits at 10.8:1, just inside the file's 10:1 floor.
Magenta was picked over staying in the indigo family because magenta was the
one spectrum hue no other surface or accent had claimed; indigo lost because
`selectionBg` already owns it alone. Blue `#141c2b` lost as the darker,
recessed alternative; green lost because `diffAdded` needs that family; warm
grey lost as the no-hue option.

**3. `bashMessageBackgroundColor` — `#16191d`, cool near-neutral slate.**
Shell command blocks and their output. This is the one surface that
deliberately takes no spectrum hue: slate is the most recessed of the
options, so long tool output stays visually quiet instead of competing with
the prose around it. Magenta `#1d1322` was the recommendation — it pairs
with `bashBorder #f5b6d8` — and was passed over in favor of quiet. Warm
amber lost because it shares a family with `warning` and `chromeYellow`;
red-brown lost because `diffRemoved` needs red.

**4. `clawd_background` — `#ff00ff`, magenta.** The backdrop behind the
mascot at startup. This slot was first set to true black, to match waybar's
`color0` and let the mascot float on foot's black with no visible block
edge. It now takes the loud magenta vignette instead: a deliberate block
edge around the mascot, paying the seam for the contrast against the spring
green body. The theme base `#0f0e14` and deep plum both lost.

**5. `selectionBg` — `#661bfd`, vivid violet.** The highlight behind the
selected row in every menu, file picker and slash-command list. It was
`#2b2545` deep indigo, inside the 10:1 floor; it is now the same vivid
violet as `permission`, so highlight and menu chip read as one element.
White clears only about 6.7:1 on it — the loudest break of the surface
rule in the file, taken for the signal.

**6. `memoryBackgroundColor` — `#0f1f22`, cyan.** The block behind `/memory`
and CLAUDE.md views. Distinct from every surface already claimed, and it
ties to `skill #9ddfe8` and `rate_limit_fill #8fd9e0`. It is the only teal
left now that the `background` accent went green, and white clears about
15:1 on it. Magenta was the warm alternative; green lost to
`diffAdded`'s family; falling back to the base lost because the memory view
would have no identity.

# Surfaces that derive rather than get chosen

`userMessageBackgroundHover` is `#4d2d54`, the magenta of surface 2 one step
lighter. `promptBorder` `#d900ff` and `promptBorderShimmer` `#3cd070` no
longer follow the sidebar's violet: the border is bright magenta and its
shimmer crosses to green, so the prompt edge pulses between the two loudest
hues in the file. `rate_limit_empty` stays neutral `#272231` so the
pastel-cyan fill carries all the color. The diff fills are semantic, not
free picks: `diffAdded #77dd77`, `diffAddedDimmed #1d2b22`,
`diffRemoved #ff6961`, `diffRemovedDimmed #2e1f24`. The two active fills
flipped from near-black tints to full pastels while the dimmed pair stayed
dark, so a diff now reads as pale blocks against dark context. `text` is
`#574785` and `inverseText` is `#ffffff`. That deep violet clears about
4.7:1 on `#77dd77`, so added-line bodies read. On `#ff6961` it clears about
2.8:1, so removed-line bodies stay hard to read until that fill goes dark.

Green is now the theme's busiest foreground family, well past the original
`success #a8e0b8` and `diffAddedWord #2f8f5a`: `claude #50c878` with
shimmer `#15dc25`, both spinner slots at `#50c878`, `clawd_body #00ff6b`,
`background #0bda51`, `planMode #0cf25a` and `promptBorderShimmer #3cd070`.
No surface takes it. Magenta sits on two surfaces — `userMessageBackground
#5d009b` and `clawd_background #ff00ff` — and still shows up in the
foreground: `promptBorder #d900ff`, `bashBorder #f5b6d8`,
`pink_FOR_SUBAGENTS_ONLY #f5b6d8`.

# The spectrum

Seven pastel hues in order, each shimmer a lighter twin: red `#ffadb0` /
`#ffd0d2`, orange `#ffc89a` / `#ffe0c4`, yellow `#f7e9a0` / `#fff5cf`, green
`#b5e8c0` / `#d6f3dc`, blue `#a8d4f2` / `#cde8fa`, indigo `#bdbdf0` /
`#d9d9f8`, violet `#e3b8ea` / `#f2d8f6`.

The eight subagent slots spread the same pastels wider apart, so two
concurrent agents stay tellable at a glance: red `#ff9fa4`, orange
`#ffbe8c`, yellow `#f2e39a`, green `#a8e0b8`, cyan `#e3b8ea`, blue
`#cfe89a`, purple `#c3b9f2`, pink `#f5b6d8`. Two of those slots do not
hold the hue they are named for: the `cyan` slot is pale violet and the
`blue` slot is pale yellow-green. The key names come from the binary and
are not renameable; only the colors moved.

# The mascot

There are exactly two mascot knobs in the binary, `clawd_body` and
`clawd_background`. No shape, pose or expression is themeable, so "as cute
as possible" comes down to one body color: `clawd_body #00ff6b`, a bright
spring green, on the magenta of the fourth surface pick above.

The mascot and the frame around it belong to the startup header, which draws
in one of two shapes. The full shape is a round frame in `claude #50c878`,
titled ` Claude Code ` on its top edge, with the mascot inside it. The small
shape is one line of version, model, billing and working directory, with no
frame and no mascot. The binary picks the full shape only when
`lastReleaseNotesSeen` in `~/.claude.json` differs from the running
claude-code version, or when `CLAUDE_CODE_FORCE_FULL_LOGO` holds any value.
The header writes that stored version itself on first render, so the full
shape draws for one session after an upgrade and the small shape every
session after it. To hold the full shape at every start, put
`CLAUDE_CODE_FORCE_FULL_LOGO` in the `env` block of
`~/.claude/settings.json`: one manual line per machine, for the same reason
the `theme` line is manual. There is no inverse knob, so neither shape can
be turned off.

# The slots that stay bright on purpose

These must interrupt, so they break the pastel rule by design: `error
#ff5c70`, `warning #ffd23f` with shimmer `#ffe88a`, `planMode #0cf25a`,
`autoAccept #1996b3` with shimmer `#e2c9ff`, `fastMode #ff7a3d` with shimmer
`#ffb086`, `effortUltra #ff6bd6`. `autoAccept` is the odd one: a deep cyan
whose shimmer stayed pale lilac, so that pair crosses hue as it pulses.

# One slot that is neither

`background` is `#0bda51`, a bright saturated green rather than a pastel.
It is not the page backdrop — the light theme sets it to a saturated hue,
which places it among the foreground accents — and `inverseText` is
plausibly the text drawn on it. It was a deep teal `#14656b`, picked so
white would read on it under either reading; at its current brightness
white would not, so this slot now bets on the accent reading being the
right one.

# Every slot, by color name

One line per key in the `.json`, same order, hex and a plain-English name.
Lives here, not in the `.json`, because the loader parses with a bare
`JSON.parse` — no comment stripping, no JSONC — so a `//` in the `.json`
throws, is caught, logged at `warn`, and the whole theme silently drops out
of the picker.

`text` `#574785` — deep violet
`inverseText` `#ffffff` — white
`inactive` `#9a93ad` — muted lavender grey
`inactiveShimmer` `#c2bcd1` — pale lavender grey
`subtle` `#7d7691` — dusty violet grey
`promptBorder` `#d900ff` — bright magenta
`promptBorderShimmer` `#3cd070` — medium green
# color of 'Tinkering' texts when thinking
`claude` `#50c878` — emerald green
`claudeShimmer` `#15dc25` — bright green
# calwd is the mascot
`clawd_body` `#00ff6b` — bright spring green
`clawd_background` `#ff00ff` — magenta
`briefLabelClaude` `#ff6b00` — bright orange
`briefLabelYou` `#a8d4f2` — pale sky blue
`bashBorder` `#f5b6d8` — pale pink magenta
`autoAccept` `#1996b3` — deep cyan
`autoAcceptShimmer` `#e2c9ff` — pale lilac
`skill` `#9ddfe8` — pale cyan
`merged` `#c3b9f2` — pale periwinkle
`effortUltra` `#ff6bd6` — hot pink
`remember` `#bdbdf0` — pale indigo
# permission coontrols the selection menu background(looked for ages to find this)
`permission` `#661bfd` — vivid violet
`permissionShimmer` `#cde8fa` — very pale sky blue
# the options underneath 'permissions' in selection menu
# Also controls the commands like '/model'
`suggestion` `#1bb2fd` — bright azure
`background` `#0bda51` — bright green
`planMode` `#0cf25a` — bright green
`ide` `#a4cdf0` — pale sky blue
`professionalBlue` `#a4cdf0` — pale sky blue
`chromeYellow` `#f7d98a` — pale gold
`claudeBlue_FOR_SYSTEM_SPINNER` `#50c878` — emerald green
`claudeBlueShimmer_FOR_SYSTEM_SPINNER` `#50c878` — emerald green
`success` `#a8e0b8` — pale mint green
`error` `#ff5c70` — bright coral red
`warning` `#ffd23f` — bright gold
`warningShimmer` `#ffe88a` — pale gold
`fastMode` `#ff7a3d` — bright orange
`fastModeShimmer` `#ffb086` — pale apricot
`diffAdded` `#77dd77` — pastel green
`diffRemoved` `#ff6961` — pastel red
`diffAddedDimmed` `#1d2b22` — dark muted green
`diffAddedWord` `#2f8f5a` — medium green
`diffRemovedWord` `#9e3047` — medium dark red
# background of user prompt
`userMessageBackground` `#5d009b` — deep purple
`userMessageBackgroundHover` `#4d2d54` — deep magenta, lighter
`composerSidebarBackground` `#141019` — near-black violet
`selectionBg` `#661bfd` — vivid violet
`bashMessageBackgroundColor` `#16191d` — near-black slate
`memoryBackgroundColor` `#0f1f22` — near-black teal
`rate_limit_fill` `#8fd9e0` — pale cyan
`rate_limit_empty` `#272231` — dark neutral violet
`red_FOR_SUBAGENTS_ONLY` `#ff9fa4` — pale coral red
`orange_FOR_SUBAGENTS_ONLY` `#ffbe8c` — pale orange
`yellow_FOR_SUBAGENTS_ONLY` `#f2e39a` — pale yellow
`green_FOR_SUBAGENTS_ONLY` `#a8e0b8` — pale mint green
`cyan_FOR_SUBAGENTS_ONLY` `#e3b8ea` — pale violet
`blue_FOR_SUBAGENTS_ONLY` `#cfe89a` — pale yellow-green
`purple_FOR_SUBAGENTS_ONLY` `#c3b9f2` — pale periwinkle
`pink_FOR_SUBAGENTS_ONLY` `#f5b6d8` — pale pink magenta
`rainbow_red` `#ffadb0` — pale red
`rainbow_orange` `#ffc89a` — pale orange
`rainbow_yellow` `#f7e9a0` — pale yellow
`rainbow_green` `#b5e8c0` — pale green
`rainbow_blue` `#a8d4f2` — pale sky blue
`rainbow_indigo` `#bdbdf0` — pale indigo
`rainbow_violet` `#e3b8ea` — pale violet
`rainbow_red_shimmer` `#ffd0d2` — very pale red
`rainbow_orange_shimmer` `#ffe0c4` — very pale orange
`rainbow_yellow_shimmer` `#fff5cf` — very pale yellow
`rainbow_green_shimmer` `#d6f3dc` — very pale green
`rainbow_blue_shimmer` `#cde8fa` — very pale sky blue
`rainbow_indigo_shimmer` `#d9d9f8` — very pale indigo
`rainbow_violet_shimmer` `#f2d8f6` — very pale violet
`diffRemovedDimmed` `#2e1f24` — dark muted red

# A note on the existing neon theme

`neon-theme.json` sets `userMessageBackground: #26ffac`, a saturated mint
in a slot the light default makes near-white, with `text` and `inverseText`
both white. White on that mint is likely unreadable. This theme does not
carry the choice forward. Fixing neon is out of scope here and untouched.
