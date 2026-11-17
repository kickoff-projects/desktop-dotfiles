# pastel rainbow — decision log

Companion to `pastel-rainbow-theme.json`. JSON takes no comments, so the
rationale for every slot lives here instead — same convention as the long
header and per-slot notes in `users/nansus/.config/waybar/colors.css`.

Every surface was chosen one slot at a time, in order of how often it is on
screen. Each entry names the options that lost and what claimed the hue, so
a later edit can tell a deliberate choice from an arbitrary one.

## The two rules everything obeys

Pastels only ever land in foreground accents, where they sit on the
terminal's near-black and clear roughly 8:1 against it. Every surface stays
at or below about `#2b2b33` luminance, so `#ffffff` clears 10:1 on it. The
classifier for which slot is which came from the binary's own light-theme
defaults: a slot that is near-white in the light theme is a surface with
text drawn on it, and a slot that is saturated is a foreground accent.

## Text

`text` and `inverseText` are both `#ffffff`. Message bodies and diff content
stay white. The named semantic slots keep their pastel hue instead of
collapsing to white, because they are UI accents rather than prose — losing
their color would cost the scannability of labels, subagent names and the
spinner. The literal white-everywhere reading was offered and declined.

## Surfaces, in the order they were decided

**1. `composerSidebarBackground` — `#141019`, faint violet.** The strip
beside the prompt, the most-seen surface claude draws. Violet was unclaimed,
sits closest to the waybar true-black base while still reading as tinted,
and white clears about 17:1 on it. Indigo lost because it was the natural
pick for the next slot; teal lost because `background` already spends a
deep teal; untinted `#121212` lost because it would leave the most-seen
surface with no identity.

**2. `userMessageBackground` — `#44274a`, deep magenta.** The block behind
everything the user types. Originally `#1b1830` indigo, but that cleared
17.2:1 against white — far darker than the binary's own dark-theme default
for this slot, `rgb(55,55,55)` = `#373737` at 11.9:1 — so it read as too
dark and was brightened to 12.8:1, just inside the file's 10:1 floor.
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

**4. `clawd_background` — `#000000`, true black.** The backdrop behind the
mascot at startup. True black matches waybar's `color0` and the neon
theme's own mascot backdrop, so the mascot floats on foot's black with no
visible block edge, and the peach-pink body pops hardest against it. The
theme base `#0f0e14` lost precisely because that seam would show; magenta
and deep plum lost as deliberate vignettes with a more obvious edge.

**5. `selectionBg` — `#2b2545`, deep indigo.** The highlight behind the
selected row in every menu, file picker and slash-command list. Indigo is
this slot's alone now that surface 2 moved to magenta; white clears about
11:1. Deep magenta was the louder signal and would have collided with
surface 2; deep teal would have muddled with the `background` accent;
neutral `#2b2b33` was the no-hue ceiling.

**6. `memoryBackgroundColor` — `#0f1f22`, cyan.** The block behind `/memory`
and CLAUDE.md views. Distinct from every surface already claimed, and it
ties to `skill #9ddfe8` and `rate_limit_fill #8fd9e0`. It shares the teal
family with the `background` accent `#14656b` but is far darker, and white
clears about 15:1. Magenta was the warm alternative; green lost to
`diffAdded`'s family; falling back to the base lost because the memory view
would have no identity.

## Surfaces that derive rather than get chosen

`userMessageBackgroundHover` is `#4d2d54`, the magenta of surface 2 one step
lighter. `promptBorder` `#3a3550` and `promptBorderShimmer` `#7b6fa8` follow
the sidebar's violet. `rate_limit_empty` stays neutral `#272231` so the
pastel-cyan fill carries all the color. The diff fills are semantic, not
free picks: `diffAdded #16301f`, `diffAddedDimmed #1d2b22`,
`diffRemoved #35161d`, `diffRemovedDimmed #2e1f24`.

Green ends up claimed by no surface at all, staying in the foreground only —
the green `success #a8e0b8` and `diffAddedWord #2f8f5a`. Magenta is now
claimed by surface 2, but still shows up in the foreground too: `bashBorder
#f5b6d8`, `pink_FOR_SUBAGENTS_ONLY #f5b6d8`.

## The spectrum

Seven pastel hues in order, each shimmer a lighter twin: red `#ffadb0` /
`#ffd0d2`, orange `#ffc89a` / `#ffe0c4`, yellow `#f7e9a0` / `#fff5cf`, green
`#b5e8c0` / `#d6f3dc`, blue `#a8d4f2` / `#cde8fa`, indigo `#bdbdf0` /
`#d9d9f8`, violet `#e3b8ea` / `#f2d8f6`.

The eight subagent slots spread the same pastels wider apart, so two
concurrent agents stay tellable at a glance: red `#ff9fa4`, orange
`#ffbe8c`, yellow `#f2e39a`, green `#a8e0b8`, cyan `#9ddfe8`, blue
`#a4cdf0`, purple `#c3b9f2`, pink `#f5b6d8`.

## The mascot

There are exactly two mascot knobs in the binary, `clawd_body` and
`clawd_background`. No shape, pose or expression is themeable, so "as cute
as possible" comes down to one body color: `clawd_body #ffc2b0`, a soft
peach-pink, on the true black of the fourth surface pick above.

## The slots that stay bright on purpose

These must interrupt, so they break the pastel rule by design: `error
#ff5c70`, `warning #ffd23f` with shimmer `#ffe88a`, `planMode #4ef0c8`,
`autoAccept #c89dff` with shimmer `#e2c9ff`, `fastMode #ff7a3d` with shimmer
`#ffb086`, `effortUltra #ff6bd6`.

## One slot that is neither

`background` is `#14656b`, a deep saturated teal rather than a pastel. It
is not the page backdrop — the light theme sets it to a saturated teal,
which places it among the foreground accents — and `inverseText` is
plausibly the text drawn on it. A deep hue means white reads on it under
either reading, which is why it is the one place the spectrum goes dark and
saturated instead of pale.

## Every slot, by color name

One line per key in the `.json`, same order, hex and a plain-English name.
Lives here, not in the `.json`, because the loader parses with a bare
`JSON.parse` — no comment stripping, no JSONC — so a `//` in the `.json`
throws, is caught, logged at `warn`, and the whole theme silently drops out
of the picker.

`text` `#ffffff` — white
`inverseText` `#ffffff` — white
`inactive` `#9a93ad` — muted lavender grey
`inactiveShimmer` `#c2bcd1` — pale lavender grey
`subtle` `#7d7691` — dusty violet grey
`promptBorder` `#d900ff` — bright magenta
`promptBorderShimmer` `#00e5ff` — bright cyan
`claude` `#ff6b00` — bright orange
`claudeShimmer` `#ff9d4d` — pale orange
`clawd_body` `#00ff02` — bright green
`clawd_background` `#000000` — black
`briefLabelClaude` `#ff6b00` — bright orange
`briefLabelYou` `#a8d4f2` — pale sky blue
`bashBorder` `#f5b6d8` — pale pink magenta
`autoAccept` `#c89dff` — pale purple
`autoAcceptShimmer` `#e2c9ff` — pale lilac
`skill` `#9ddfe8` — pale cyan
`merged` `#c3b9f2` — pale periwinkle
`effortUltra` `#ff6bd6` — hot pink
`remember` `#bdbdf0` — pale indigo
`permission` `#a8d4f2` — pale sky blue
`permissionShimmer` `#cde8fa` — very pale sky blue
`suggestion` `#9fb8d9` — muted sky blue
`background` `#14656b` — deep teal
`planMode` `#4ef0c8` — bright mint
`ide` `#a4cdf0` — pale sky blue
`professionalBlue` `#a4cdf0` — pale sky blue
`chromeYellow` `#f7d98a` — pale gold
`claudeBlue_FOR_SYSTEM_SPINNER` `#a4cdf0` — pale sky blue
`claudeBlueShimmer_FOR_SYSTEM_SPINNER` `#cde8fa` — very pale sky blue
`success` `#a8e0b8` — pale mint green
`error` `#ff5c70` — bright coral red
`warning` `#ffd23f` — bright gold
`warningShimmer` `#ffe88a` — pale gold
`fastMode` `#ff7a3d` — bright orange
`fastModeShimmer` `#ffb086` — pale apricot
`diffAdded` `#16301f` — very dark green
`diffRemoved` `#35161d` — very dark red
`diffAddedDimmed` `#1d2b22` — dark muted green
`diffAddedWord` `#2f8f5a` — medium green
`diffRemovedWord` `#9e3047` — medium dark red
`userMessageBackground` `#b84dff` — bright purple
`userMessageBackgroundHover` `#4d2d54` — deep magenta, lighter
`composerSidebarBackground` `#141019` — near-black violet
`selectionBg` `#2b2545` — deep indigo
`bashMessageBackgroundColor` `#16191d` — near-black slate
`memoryBackgroundColor` `#0f1f22` — near-black teal
`rate_limit_fill` `#8fd9e0` — pale cyan
`rate_limit_empty` `#272231` — dark neutral violet
`red_FOR_SUBAGENTS_ONLY` `#ff9fa4` — pale coral red
`orange_FOR_SUBAGENTS_ONLY` `#ffbe8c` — pale orange
`yellow_FOR_SUBAGENTS_ONLY` `#f2e39a` — pale yellow
`green_FOR_SUBAGENTS_ONLY` `#a8e0b8` — pale mint green
`cyan_FOR_SUBAGENTS_ONLY` `#9ddfe8` — pale cyan
`blue_FOR_SUBAGENTS_ONLY` `#a4cdf0` — pale sky blue
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

## A note on the existing neon theme

`neon-theme.json` sets `userMessageBackground: #26ffac`, a saturated mint
in a slot the light default makes near-white, with `text` and `inverseText`
both white. White on that mint is likely unreadable. This theme does not
carry the choice forward. Fixing neon is out of scope here and untouched.
