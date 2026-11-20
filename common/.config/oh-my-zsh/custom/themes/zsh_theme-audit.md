# Audit: `zsh_theme`

Audited file: `common/.config/oh-my-zsh/custom/themes/zsh_theme` (121 lines), the
shared oh-my-zsh prompt theme sourced by `system/base/shells/zsh.nix:42-45`.
Nothing else in the repo was audited. Load assumed: one person, one interactive
shell at a time, prompt redrawn a few times per second at most.

Date: 2026-11-19. Report only, no code changed.

## 1. Continuation prompt draws red, not gray (`zsh_theme:118`)

- **What this is:** `PROMPT2` is the marker zsh shows on the next line while a
  command is unfinished.
- **Problem:** `$fg[gray]` is a zsh alias for ANSI color 0 (verified:
  `fg[gray]` == `fg[black]` == `\e[30m`). This repo's foot palette sets
  `regular0 = "d32f2f"` (`common/palettes.nix:33` and `:55`), so ANSI 0 is red.
  The `\` renders in the same red used for errors and for root. The comment
  "Resets color idk" shows the color was never confirmed.
- **Fix:** one line. Use an index outside the remapped 0-15 block:

  ```zsh
  PROMPT2='%F{244}\ %{$reset_color%}'
  ```

  If you want a palette color instead, `$fg[white]` maps to
  `regular7 = "607d8b"`, the actual grey-blue in the scheme.
- **If we skip it:** An unfinished command looks like a failure. Cosmetic only,
  nothing breaks.

Positions 2-7 of the palette match standard ANSI semantics, and `regular1`
(`ff4081`) is still a red, so only position 0 is anomalous. This is a one-line
defect, not a reason to convert the file to explicit `%F{N}` indices.

## 2. One glyph breaks the file's own font rule (`zsh_theme:18`, rule at `:24-26`)

- **What this is:** `ZSH_THEME_GIT_PROMPT_DIRTY` is the marker appended to the
  branch name when the working tree has changes.
- **Problem:** Lines 24-26 state the rule: glyphs stay inside U+F000-U+F381,
  which FiraCode Nerd Font Mono covers. The ten status symbols on lines 27-39
  all obey it (each checked against `fc-query --format %{charset}` on
  `FiraCodeNerdFontMono-Regular.ttf`: all present). Line 18 uses U+E4D0, which
  that font does **not** cover. Same file, same purpose, rule applied two ways.
- **Fix:** swap U+E4D0 for a codepoint in F000-F381, the same range the ten
  symbols already use.
- **If we skip it:** It renders today, via fontconfig falling back to Font
  Awesome 7 Free Solid (which does cover U+E4D0, and is installed system-wide at
  `system/base/fonts.nix:12`). The rule in the comment is simply untrue for this
  one line, so the next edit may trust it wrongly.

## 3. PROMPT glyphs outside FiraCode, covered only by fallback (`zsh_theme:82-84`)

- **What this is:** The decorative glyphs in the main prompt lines.
- **Problem:** U+E599, U+F595, U+E52F, U+F740, U+E5AA and U+E546 are absent from
  FiraCode Nerd Font 3.4.0 (Nerd Fonts v3 relocated the legacy v2 private-use
  codepoints). They render only because `font-awesome` is in `fonts.nix` and
  fontconfig falls back to it. U+F188 and U+F25B are genuinely in FiraCode.
- **Fix:** None needed now. If you ever want the prompt to stand on the
  configured `font=FiraCode Nerd Font Mono` alone, pick replacements from the
  covered ranges `e000-e00a`, `e0a0-e0a3`, `e0b0-e0d7`, `e200-e2a9`,
  `e300-e3e3`, `e5fa-e6b8`, `e700-e8ef`, `f000-f381`, `f400-f533`.
- **If we skip it:** Nothing on any host in this repo. The prompt breaks only on
  a machine that has FiraCode but not font-awesome.

## 4. `NCOLOR` is dead (`zsh_theme:1-2`)

- **What this is:** A variable meant to color part of the prompt red when running
  as root.
- **Problem:** Nothing reads it. Grepped the whole tree: the only other hits are
  two sibling copies of this same theme that also only set it, never use it.
  Root is already marked by the glyph in `%(!.<glyph>.$)` on line 84.
- **Fix:** delete both lines.
- **If we skip it:** Two lines a reader has to trace before concluding they do
  nothing.

## 5. Commented-out prompt history (`zsh_theme:5, 67-71, 86-90, 92-95, 105-112, 120`)

- **What this is:** Earlier symbol sets, earlier prompts, a glyph scratchpad, and
  the disabled `return_code`.
- **Problem:** About 21 commented lines, plus `${return_code}` still expanding to
  nothing inside `RPS1` on line 103.
- **Fix:** Your call, not a defect. Lines 6-7 already document that
  `${return_code}` contributes nothing, and lines 67 and 92 label their blocks as
  history, so these are recorded decisions. Delete if you no longer want to
  switch back; the git log keeps them either way.
- **If we skip it:** The file stays 121 lines where roughly 95 are live.

## 6. Nine subshells per prompt redraw (`zsh_theme:58-65, 83`)

- **What this is:** Each `$(...)` in a prompt forks a subshell every time the
  prompt is drawn.
- **Problem:** Line 83 has five. `git_group_open` and `git_group_close` each fork
  again for `$(git_prompt_info)` and `$(git_prompt_status)`, so nine total. None
  of them runs git: confirmed in `oh-my-zsh/lib/git.zsh:147-184` that with zsh
  5.0.6+ both functions only echo the cached `_OMZ_ASYNC_OUTPUT` entry, and that
  the async handler registers only if the literal `$(git_prompt_info)` /
  `$(git_prompt_status)` appears in a prompt variable - exactly as the comments on
  lines 11-13 and 54-57 say.
- **Fix:** Optional. Cache both strings in a `precmd` hook into two plain
  variables, then have the helpers test those. Saves four forks and costs a hook.
- **If we skip it:** A few hundred microseconds per redraw. Not measurable in use.

## Verdict

Healthy. One real color bug (finding 1), one comment that contradicts its own
line (finding 2). Fix 1 first - it is one line.

Lean: -23 lines possible, -0 dependencies.

## Checked and correct

These were suspected and cleared, so do not re-raise them:

- `%(!.<glyph>.$)` on line 84 is not an empty root branch. The root branch holds
  U+F25B; the file's byte content was checked with `cat -A`.
- The async mechanism and the "must appear verbatim in PROMPT" claim on lines
  11-13 and 54-57 are accurate against the installed oh-my-zsh.
- The "all ten symbols must be set" requirement on line 23 is accurate:
  `_omz_git_prompt_status` builds `constant_prompt_map` from all ten variables.
- The DIVERGED note on lines 36-38 is accurate: git emits `ahead`/`behind`, never
  `diverged`, in `git status -b`.
- `ZSH_THEME_VIRTUALENV_PREFIX=""` / `SUFFIX=""` on lines 51-52 correctly suppress
  the plugin's default brackets, because the plugin uses `${VAR=[}`, which honors
  a set-but-empty value. The `virtualenv` plugin is enabled at
  `system/base/shells/zsh.nix:23`.

## Not checked

- Only `zsh_theme` was audited. `common/palettes.nix`, `hosts/*/.config/foot/`
  and `system/base/shells/zsh.nix` were read for evidence but not audited.
- Glyph shapes were not inspected in a terminal, only font coverage.
- The claim that proportional-font fallback clips or misaligns in foot was not
  verified, so finding 3 does not assert it.
- `users/nansus-work/.config/oh-my-zsh/custom/themes/zsh_theme` declares itself a
  derived copy of this file (its lines 1-8) and already diverges by using
  explicit `%F{N}` indices. Any fix here must be mirrored there or the two drift
  further.
