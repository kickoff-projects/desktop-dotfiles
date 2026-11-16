# changes.md

What this working copy does differently from the original `.dotfiles`. Newest work at the top.
Line counts are added/removed per file.

---

## 2026-11-15: kakoune and foot palettes generated, not hand-copied

Follow-up to the 2026-11-14 refactor. Asked directly whether the common/hosts/users layering was
reasoned independently of `/srv/nixos-vm-config` or just copied from it. The
overlay *mechanism* is independently justified (same principle as a dotfile-manager symlink farm),
but hand-copying whole palette files per theme was taken from vm-config without separately
checking whether generation would be better. For kakoune and foot, which are both already
16-slot color tables, it would.

### Added

- **`common/palettes.nix`**: each theme's kakoune (base16-shaped) and foot color sets, as plain
  Nix data. The two are kept independent per theme on purpose: the existing rainbow kakoune scheme
  (mellow-purple) and the existing rainbow foot scheme ("space rainbow") were authored
  independently for their own tool, so merging them into one hex set would have changed what
  currently renders.
- **`common/lib/render-kak.nix`**, **`common/lib/render-foot-colors.nix`**: the ~140-line
  `set-face` body (identical across every theme, confirmed by diff before this landed) and the
  foot INI shape, each written once as a template instead of three times as a file.
- **`hosts/Server/theme.nix`**: sets the Server's kak+foot override with `lib.mkForce`.
  `flake.nix`'s `homeFor` imports a host's `theme.nix` automatically when present, same
  conditional-import pattern as `hostDir/.config`.

### Changed

- `common/home.nix` sets `kak/colors/account.kak` and `foot/colors.ini` via `lib.mkDefault
  (renderKak …)` / `lib.mkDefault (renderFootColors …)` instead of letting the directory-scan
  overlay pick up a plain file at those paths.
- `users/nansus-work/home.nix` overrides only `kak/colors/account.kak` with `lib.mkForce`. foot
  stays untouched, so it's still rainbow for that account, same as before this change.
- `hosts/LiveUSB/configuration.nix` renders both files inline via `environment.etc."...".text`
  instead of `.source`-ing a checked-in file; no home-manager there, so this is `mkForce`'s
  equivalent for a host that has no home-manager layer to force it through.

### Deleted

The now-generated hand files: `common/.config/kak/colors/account.kak`,
`users/nansus-work/.config/kak/colors/account.kak`, `hosts/Server/.config/kak/colors/account.kak`,
`common/.config/foot/colors.ini`, `hosts/Server/.config/foot/colors.ini`,
`hosts/LiveUSB/.config/foot/colors.ini`, `hosts/LiveUSB/.config/kak/colors/account.kak`. The
13-file kakoune color *library* (`purple_best.kak` and friends, for manual switching) is
untouched. Only the file named `account.kak` is generated.

### Verified

- Rendered every theme/surface combination and diffed against the file it replaced before
  deleting anything: rainbow kak, red kak (both copies), rainbow foot, red foot all came back
  byte-identical except for two pre-existing things, both kept as they were: a comment
  in the rainbow kak file names a different hex (`3d85c6`) than the color it's commenting on
  uses (`5191cc`), a mismatch that already existed in the hand file and is now recorded
  as `commentAD01` in `palettes.nix`, unresolved; and the foot files' header
  comments, which I'd written myself during the first pass and updated to describe generation
  instead of hand-authorship (not data, so not a parity concern).
- Re-ran the precedence check from the first pass, now against `.text` values instead of
  `.source` paths: `nansus@Home-Laptop` → rainbow kak + rainbow foot; `nansus-work@Home-Laptop` →
  red kak + **rainbow** foot (confirming the override is scoped to kak only); `nansus@Server` →
  red kak + red foot; LiveUSB's `environment.etc` → red kak + red foot. All five matched.
- Face-set diff re-run against the *generated* output (as well as the old hand files), still
  identical between themes.
- All four `nixosConfigurations` and five `homeConfigurations` still evaluate. File count: 140 → 137.

---

## 2026-11-14: Shared base, per-account color schemes, Slave → Server

The big one: deduplicated the five near-identical `.config` trees into `common/` + `hosts/` +
`users/` (mirroring `/srv/nixos-vm-config`'s `common`/`users` split, extended with a host layer
since this repo has four machines instead of one), made color scheme a per-account choice instead
of a per-host one, renamed `Slave` to `Server` and moved it onto sway, and collapsed the two Work
`nixosConfigurations` now that leisure/work software lives in `home.packages` and has left the
system config. Full plan: `/home/user/.claude/plans/this-codebase-is-a-hidden-umbrella.md`.

### Added

- **`common/config-files.nix`**: ported from `/srv/nixos-vm-config/common/config-files.nix`,
  turns a directory into per-file `xdg.configFile` entries, with a `pathExists` guard for a
  missing layer.
- **`common/home.nix`**: the shared home-manager base (git identity, `seedBtopConfig`, now
  extended to reseed when the existing `btop.conf` names a theme path that no longer exists;
  `programs.ssh.enable = false`; `direnv`; `playerctl` for the shared media binds) plus the
  three-layer `xdg.configFile` merge: `common/.config` // `hostDir/.config` // `users/<name>/.config`.
- **`common/system.nix`**: the NixOS module list and `nansus` user/group block every machine
  takes, replacing ~30 repeated import lines per host.
- **`common/.config/`**: everything that was byte-identical across Home-Laptop and Home-Desktop:
  `hyprland.conf`, `hyprpaper.conf` (now pointing at `~/.config/wallpaper/...` instead of a
  hardcoded `/home/nansus/.dotfiles` or `/home/nansus/desktop-dotfiles`, whichever didn't match
  the host), `UserConfigs/{Animations,Decorations,Execs,StartPrograms,Vim-submap,WindowRules}.conf`,
  `scripts/smooth_RainbowBorder.sh`, `waybar/style.css` (the superset of both hosts' selectors;
  the two differed because of the `pulseaudio#microphone` vs `custom/microphone` module split,
  not the palette), `foot/colors.ini`, `btop/btop.conf.in`, `rofi/config.rasi`, the kakoune
  library and `kakrc`, `fastfetch/config.jsonc` + logos, `oh-my-zsh/custom/themes/zsh_theme`, and
  one `nixpkgs/config.nix`.
- **`common/.config/waybar/colors.css` + `effects.css`**: the `@define-color` block and the
  `@keyframes` split out of `style.css`. A host or user layer replaces either to switch the
  theme without touching the ~350 lines of selectors.
- **`common/.config/hypr/UserConfigs/palette.conf`**: replaces `wallust/wallust-hyprland.conf`;
  `Decorations.conf` now sources `~/.config/hypr/UserConfigs/palette.conf` instead of the
  hardcoded `/home/nansus/.config/wallust/wallust-hyprland.conf`, which meant `nansus-work` never
  got a palette at all.
- **`common/.config/kak/colors/account.kak`**, **`btop/themes/account.theme`**,
  **`rofi/account.rasi`**: the same fixed-filename-indirection pattern for kakoune, btop and
  rofi. `rofi/config.rasi` no longer points at a nix-store path
  (`/nix/store/...-rofi-1.7.5+wayland3/.../Arc-Dark.rasi`) that breaks on every rofi bump.
- **`common/.config/hypr/UserConfigs/Keybinds.conf`**: one merged shared file: Home-Laptop's
  `code` bind and brightness binds (F5/F6), plus Home-Desktop's F9-F12 audio row and SHIFT-mic
  variants. Per instruction, uniform binds on every host even where the software isn't installed
  yet.
- **`users/nansus/home.nix`**, **`users/nansus-work/home.nix`**: the account-level package
  lists (see "Moved to home.packages" below). `nansus-work` additionally carries a Rust toolchain
  and Python/uv.
- **`users/nansus-work/.config/kak/colors/account.kak`**: the one file the work account
  overrides: red, copied verbatim from `/srv/nixos-vm-config/users/user/.config/kak/colors/account.kak`.
  Everything else (waybar, borders, zsh) stays rainbow for this account, per instruction.
- **`hosts/Server/.config/{sway,waybar,foot,kak,btop,rofi}/`**: the Server's full red palette
  set, same reference files, plus `sway/config` and `sway/colors` (see below) and a flat
  single-stop `waybar/effects.css` (every keyframe common's style.css animates is still defined,
  just holding one color, so nothing references an undefined keyframe).

### Moved to `home.packages`

Plain packages moved off the system config and onto the account that uses them, so the two
leisure machine configs and the Server no longer need their own copy of software that isn't
`programs.*.enable`-shaped: discord, spotify, prismlauncher, FreeCAD, qemu, libreoffice-qt,
dolphin, zen-browser, proton-vpn, openconnect, feh, claude-code (→ `users/nansus`); rustc/cargo
toolchain, uv, python3, libreoffice-qt, openconnect, proton-vpn (→ `users/nansus-work`, new).
`programs.steam.enable` and `gamemode.enable` stay system-level on the two leisure hosts (steam
needs firewall openings and `hardware.graphics.enable32Bit`, which can't move to a home module),
so `nansus-work` sees steam installed but unused on those two machines.

This is what let the two Work `nixosConfigurations` collapse: once software is per-account, a
leisure and a work machine config are identical, so there was nothing left to carry a separate
`Home-Desktop-Work` / `Home-Laptop-Work` system for.

### Renamed

- `hosts/Laptop/` → `hosts/Home-Laptop/`; `hosts/Slave/` → `hosts/Server/`. Every host directory
  now has `configuration.nix` + `hardware.nix` (was `Laptop-hw.nix` / `Desktop-hw.nix` /
  `Slave-hw.nix` / `liveusb.nix`), named for role, and the directory name equals
  the flake attribute: `hosts/Home-Laptop` builds `.#Home-Laptop`, so no mapping table is needed.
- Flake attribute `Slave` → `Server`; home key `nansus@Slave` → `nansus@Server`;
  `networking.hostName`: `"Slave"` → `"NixOS-Server"`, `"liveusb-nix"` → `"hassus"` (and the
  `specialArgs.hostname` indirection LiveUSB alone used is gone, and it's a plain line in its
  `configuration.nix` now, like every other host).
- `system/base/hostnames/{Laptop,Home-Desktop,Slave}.nix` (three 8-line files) collapsed into one
  `networking.hostName` line per host.
- `system/games/tailscale.nix` → `system/security/tailscale.nix` (it's a VPN mesh, not a game).

### Server runs sway, not hyprland

`base/hyprland.nix` is gone from the Server; it gets `programs.sway.enable` instead. Nothing in
`hosts/Server/.config/hypr/` survived. sway has no blur/shadow/decoration block at all, so
"strip the effects" needed no configuring, just not being hyprland. Binds in
`hosts/Server/.config/sway/config` are translated from the shared `Keybinds.conf` (`bindsym`
instead of `bind`, same mod key and letters where sway has an equivalent); layout tricks and the
Vim submap have no sway equivalent and are dropped there. Screenshot binds keep their keys
(`Ctrl+Shift+X/A/S`) but call `grim`+`slurp` instead of `hyprshot`, since `screen_shot.nix`'s
tools are hyprland-only: the Server gets `grim`, `slurp`, `jq`, `wl-clipboard` in its own
`environment.systemPackages` instead of importing that module. Waybar's workspace module is
`"sway/workspaces"`, not `"hyprland/workspaces"`. `hosts/Server/.config/sway/colors` is the exact
`client.focused`/`client.unfocused` file from `/srv/nixos-vm-config/users/user/.config/sway/colors`.

### Deleted

- `hosts/Work/` entirely (two system configs, their `.config` trees, their `home.nix`),
  `system/base/shells/work_zsh.nix`, `system/games/ydotool.nix` (only Home-Desktop imported it,
  nothing calls `ydotool`), `system/base/keymap.nix` (superseded duplicate of
  `UserConfigs/Settings.conf`'s `kb_layout`, still spelled the renamed `xkbOptions`),
  `system/base/kernel.nix` (entirely commented out, set nothing), `system/base/hostnames/`,
  three orphaned `hosts/*/home.nix` files once their content moved to `common/home.nix` /
  `users/*/home.nix`.
- `testing_stuff_-beware-/` (880 lines, unreferenced, own README said to stay out), all `kitty/`
  directories and the `kitty` package (commented out of `hyprland.nix`, never installed
  on Laptop/Home-Desktop despite the configs existing; `$terminal` was already `foot`
  everywhere), `neofetch/` on four hosts (every greeting runs `fastfetch`), `emacs/` +
  the committed compiled `.eln` binary, waybar/fastfetch parked variants
  (`2nd_config.jsonc`, `multi_output_config*.jsonc`, `original_style.css`,
  `config-compact/pokemon/v2.jsonc`, `config.jsonc.bak`), duplicate logo/theme/nixpkgs-config
  copies that were byte-identical to a file already kept.
- The `flake-utils` and `sops-nix` flake inputs and every `sops-nix.nixosModules.sops` reference
  (AUDIT #18), which closes it by removal.

### Not changed

- Laptop and Home-Desktop's rainbow scheme: unchanged, by instruction. They're the reference.
- `system/security/sshd.nix` stays as a file; its import is commented out on every host
  (AUDIT #19 closed by removing the service, not declaring keys; the headless Server has no
  remote access now and is rebuilt at the machine).
- AUDIT #11 (double terminal on login) and AUDIT #22 (uniform-but-sometimes-inert binds):
  left as recorded in `AUDIT.md`.
- Commented-out module imports (`Docker.nix`, `virt-manager.nix`, `VirtualBox.nix`,
  `terminator.nix`, `roccat.nix`, `mitmproxy_cert.nix`): still kept on purpose.
- The 13 kakoune color schemes beyond `account.kak`/`purple_best.kak`: kept as a library, one
  shared copy instead of five. `colors/absolute_best/purple_best.kak` differed from
  `colors/purple_best.kak`, so it's `colors/purple_best-absolute.kak` now and was not discarded.
- All six wallpaper images: moved to `common/.config/wallpaper/` (so hyprpaper's checkout-path
  bug above is fixed), not deleted.

### Verified

- `nix flake show`: all four `nixosConfigurations` (`Home-Desktop`, `Home-Laptop`, `Server`,
  `LiveUSB`) and `homeConfigurations` evaluate.
- Each `nixosConfigurations.*.config.system.build.toplevel.drvPath` evaluates to a real
  derivation, with the hostname baked into the derivation name confirming the rename:
  `nixos-system-NanSuS-Desktop`, `nixos-system-NanSuS-Laptop`, `nixos-system-NixOS-Server`,
  `nixos-system-hassus`.
- Each of the five `homeConfigurations.*.activationPackage.drvPath` evaluates.
- `environment.systemPackages` diffed per host: Home-Laptop/Home-Desktop carry hyprland, steam,
  gamemode, screen_shot's hyprshot/grimblast/hyprpicker; Server carries sway, grim/slurp instead,
  no steam/gamemode, no bluez. Confirms `common/system.nix` didn't leak the wrong packages onto
  the wrong host.
- Layer-merge precedence checked directly via `config.xdg.configFile.<path>.source`:
  `nansus@Home-Laptop` resolves `waybar/colors.css` to `common/`; `nansus@Server` resolves the
  same key to `hosts/Server/`; `nansus-work@Home-Laptop` resolves `kak/colors/account.kak` to
  `users/nansus-work/` while every other key (`waybar/colors.css` included) still resolves to
  `common/`. All five came out exactly as the account/host split intends.
- The rainbow and red `account.kak` schemes declare the same `set-face` targets and the same
  `declare-option` names, so no face bleeds through when switching between them.

---

## 2026-11-12: Laptop's zsh prompt, tighter waybar, SUPER/ALT swapped

- `hosts/Home-Desktop/.config/oh-my-zsh/custom/themes/zsh_theme` is now a copy of
  `system/base/shells/oh-my-zsh/custom/themes/zsh_theme`, the theme the Laptop uses.
- `system/base/shells/zsh.nix` `promptInit` tries `~/.config/oh-my-zsh/custom/themes/zsh_theme`,
  then `~/.dotfiles/…`, then `~/desktop-dotfiles/…`. The single hardcoded `~/.dotfiles` path never
  resolved in this clone, so the desktop had no theme at all. The Laptop still lands on
  `~/.dotfiles/…`.
- waybar `config.jsonc`: `"height"` 26 → 30, `"spacing"` 8 → 2.
- waybar `style.css`: modules 15 → 17px, clock 14 → 16px, workspaces 14 → 16px, `#network`
  `margin` `0 30px` → `0 2px`.
- waybar `config.jsonc` `clock` format: the 3-space runs around the separator glyphs and before
  the week number cut to one, and `#clock` `margin` `0px 3px` → `0 2px`.
- waybar `config.jsonc` format strings: the runs of 3-4 literal spaces between a glyph and its
  value in `cpu`, `memory`, `network`, `battery` and `custom/nvidia` cut to one or two, and the
  trailing padding inside `format-wifi`, `format-ethernet`, `format-plugged`, `format-charging`
  and `format-muted` dropped. That padding sat inside each module, so it widened the coloured
  underline too; they now sit as tight as `#tray`.
- `hosts/Home-Desktop/.config/hypr/UserConfigs/Settings.conf`:
  `kb_options = altwin:swap_lalt_lwin, grp:ctrls_toggle`, the Laptop's line. The layout toggle
  moves from ALT+SHIFT to both-CTRLs with it.
- `hosts/Home-Desktop/.config/hypr/UserConfigs/Keybinds.conf`: audio on the bare F-row (F9 mute,
  F10 volume down, F11 volume up, F12 mic mute) alongside the existing `XF86Audio*` binds. The
  two `brightnessctl` binds on F5/F6 are deleted; there is no `/sys/class/backlight` on this host,
  so they did nothing but swallow the keys. This file no longer matches the other four hosts.
- Verbose comments in all four files cut down to one line each.

Not applied yet: `sudo nixos-rebuild switch --flake .#Home-Desktop` for the shell and keyboard,
`home-manager switch --flake .#nansus@Home-Desktop` for waybar and the theme file.

## 2026-11-06 (third pass): one shared keybind file, Laptop's hypr layout everywhere

Follow-ups you asked for: drop ROCm entirely, give every user Laptop's keybinds and
`UserConfigs/` structure, delete the comments whose code was removed, and drop Iosevka.

### ROCm removed completely

`system/hardware/amd_opengl.nix` is deleted and its import removed from Home-Desktop. With Intel
graphics on the desktop as well, no machine in this repo can use an AMD compute runtime, so the
split module from the previous pass had nothing left to serve. `opengl.nix` keeps only
`hardware.graphics.enable = true`.

### One shared `Keybinds.conf`

`hosts/Laptop/.config/hypr/UserConfigs/Keybinds.conf` is now byte-identical across all five hosts
(verified: a single md5 across the five files). Two corrections were made to it first, because both
were broken for every host including the Laptop:

- `bind = $mainMod, B, exec, foot btop --config ~/.dotfiles/hosts/Laptop/.config/btop/btop.conf`
  became `bind = $mainMod, B, exec, $terminal btop`. The old form hardcoded the Laptop's path, and
  that path stopped existing when `btop.conf` became `btop.conf.in`. btop reads
  `~/.config/btop/btop.conf` by default, which the activation step seeds, so no `--config` is needed.
- `$terminal`, `$fileManager` and `$menu` were defined in both `Keybinds.conf` and
  `StartPrograms.conf`, and `StartPrograms.conf` is sourced second, so its values won. That is why
  `$menu` was still `wofi` on the Laptop even after the earlier fix. The trio now lives once, in
  `Keybinds.conf`. The `exec-once` lines in each `StartPrograms.conf` are untouched and still
  differ per host.

`$terminal` is `foot` in the shared file, so `system/base/foot/foot.nix` is now imported on
Home-Desktop, Slave and both Work hosts as well, one line each. kitty stays installed where it was.

The Laptop file had no brightness binds at all, so copying it everywhere would have dropped the
F6-up / F5-down fix from the previous pass. A `# -------- Brightness Settings -------------`
section was added to the shared file instead, so all five hosts have it and the file stays
identical everywhere. F5 and F6 collide with nothing in it, and `brightnessctl` comes from
`system/base/hyprland.nix` on every host.

Side effect worth knowing: every host now closes Hyprland with `CTRL SHIFT, 0`, the Laptop's key,
instead of `$mainMod, M`. That is the key you wanted for dropping back to gdm to switch users.

### Laptop's `UserConfigs/` layout everywhere

All five hosts now carry exactly the same ten files, and all five `hyprland.conf` files list the
same ten `source=` lines in the same order (`Vim-submap.conf` commented out, as on the Laptop).

- **Home-Desktop, Slave**: gained `Vim-submap.conf` and the commented source line.
- **Work/Home-Laptop-Work**: gained `Execs.conf` and `Vim-submap.conf`. Its `Execs.conf` keeps the
  rainbow-border exec **commented out**, which is how that host had it, so its behaviour does not
  change.
- **Work/Home-Desktop-Work**: the real restructure. Its `hyprland.conf` was a 246-line monolith
  that sourced nothing, so its `UserConfigs/` files were dead. Now:
  `ENVariables.conf` → `ENV-Variables.conf`, `UserAnimations.conf` → `Animations.conf`,
  `UserDecorations.conf` → `Decorations.conf`, `UserSettings.conf` → `Settings.conf`; new
  `Monitors.conf` holding its three monitors and workspace pins, new `StartPrograms.conf` holding
  its `exec-once` block, plus `Keybinds.conf`, `Execs.conf` and `Vim-submap.conf`. `hyprland.conf`
  is now the same sourcing stub as the Laptop's. The old file set covered every section the
  monolith had (`general`, `decoration`, `input`, `gestures`, `misc`, `binds`, `xwayland`,
  `render`, `animations`, window rules), so nothing was lost. The two cursor-size `env` lines that
  only existed in the monolith were appended to `ENV-Variables.conf`. The upstream example
  `device { name = epic-mouse-v1 }` block was not carried over, because that mouse does not exist.

### Comments whose code was removed: deleted

`# update, upgrade easier to remember xd` in `zsh.nix`, `#Enable git` in all five `home.nix` files,
the `#userName` / `#userEmail` pair in `hosts/Laptop/home.nix`, and the Vimjoyer/LibrePhoenix pair
above the deleted `start_hyprland.sh` calls. Comments whose code is still there were left alone,
including `#../../system/base/hostnames/Laptop.nix`, `#source-code-pro` and `#iosevka-bin`.

### Iosevka removed

`nerd-fonts.iosevka` is out of `system/base/fonts.nix`, along with the note above it. `monospace`
was pointing at `"Iosevka Nerd Font"`, so it now says `"FiraCode Nerd Font"`. Otherwise removing
the package would have recreated the exact fallback bug from finding 16. `serif` and `sansSerif`
stay on `"Source Code Pro"`, which is installed.

### Dead binds the shared file creates: your call

Checked by evaluating each host's package set. These binds exist on every host but only work where
the program is installed:

- `$mainMod, F` and `CTRL SHIFT, F` (zen, zen private): Laptop only.
- `$mainMod, V` (protonvpn-gui): Laptop only.
- `$mainMod, C` (code): works everywhere **except** the Laptop, whose `home.nix` has vscode
  commented out.
- `CTRL SHIFT, X / A / S` (hyprshot): Home-Desktop and Laptop only; `screen_shot.nix` is not
  imported on Slave or either Work host.
- `$mainMod, D` (discord) and `$mainMod, S` (steam): not on either Work host.
- The four `XF86Audio` media binds use `playerctl`, which is not installed on any host.

Everything else resolves everywhere: foot, dolphin, rofi, thunar, btop, `wpctl` for volume,
`hyprctl`, `pkill`.

### Verified

All six machine configurations and all five home configurations still evaluate to a derivation.
The five `UserConfigs/` directories hold the same ten filenames; the five `Keybinds.conf` files
hash to one value; the five `hyprland.conf` source lists are identical.

## 2026-11-06 (later): applied audit findings 1, 4-10, 12-17, 20

Findings 11, 18 and 19 were not selected and are untouched. Repo went from 516 to 263 files.

Comments were again left byte-identical: every surviving comment in every file touched this round
is unchanged, verified by comparing the comment lines before and after. Where a fix removed the
statement a comment sat above, the comment was left in place and not deleted (see "orphaned
comments" at the end).

### Added

- **`system/base/users/work_user.nix`**: unchanged from earlier today.
- **`system/base/shells/work_zsh.nix`** (76 lines, vs 134 in `zsh.nix`): finding 6. The two Work
  hosts now take this instead of `zsh.nix`: same zsh, oh-my-zsh and history setup, but only the
  nix rebuild helpers, the `lsd` aliases, `pk` and `.d`/`.s`. The nmap block, the steam and discord
  kills, the HTB and school paths, `vpn`, `img`, `speed` and `lab` are not on the work machines.
  It sets `users.users.nansus.shell = pkgs.zsh;` because `zsh.nix` is no longer imported there.
- **`system/app/dolphin.nix`**: finding 10. Installs `pkgs.kdePackages.dolphin`, which is what
  `$fileManager` has always pointed at. Imported on Home-Desktop, Laptop, Slave and both Work hosts.
- **`system/hardware/amd_opengl.nix`**: finding 14. Holds the `rocmPackages.clr.icd` line that
  used to sit in the shared `opengl.nix`. Imported only on Home-Desktop.

### Changed

- **`system/base/shells/zsh.nix`**: finding 1: deleted `alias update=…` and `alias upgrade=…`,
  both of which hardcoded `.#Home-Laptop` and would have rebuilt the laptop's configuration on the
  desktop or Slave. `hms` and `nrs` remain and take the host as an argument. Finding 20: `ncgo`
  now uses `-d` instead of `--d`, which is not a flag. Also guarded the theme `source` line with
  `[ -f … ] &&`, because `promptInit` runs for every user and only `nansus` has `~/.dotfiles`.
- **`flake.nix`**: finding 5: `pkgs` removed from all four remaining `specialArgs` blocks, so
  `nixpkgs.config` is no longer ignored on four machines out of six; each
  `configuration.nix` already sets `allowUnfree`. Finding 6: the five duplicate
  `./system/base/shells/zsh.nix` lines deleted. Finding 7: `nixpkgs` dropped from LiveUSB's
  `specialArgs`. Finding 20: the git identity moved into the shared `basics` and `workBasics`
  bindings, in the current `settings.user.name` / `settings.user.email` spelling, which also
  silences the deprecation warnings the old `userName` / `userEmail` produced. Finding 9: both
  bindings are now `{ lib, ... }:` modules and carry a `seedBtopConfig` activation step.
- **`hosts/{Home-Desktop,Laptop,Slave}/configuration.nix`**: finding 7: the unused `system`
  argument removed from the module header. Finding 10: `dolphin.nix` imported. Finding 14:
  Home-Desktop also imports `amd_opengl.nix`. Finding 15: `power.nix` import removed from
  Home-Desktop and Slave, which have no battery; `CPU_MAX_PERF_ON_AC = 90` was holding the ML
  box below full speed. The Laptop keeps TLP.
- **`hosts/Work/{Home-Desktop-Work,Home-Laptop-Work}/configuration.nix`**: `work_zsh.nix` in
  place of `zsh.nix`, `dolphin.nix` imported, and `power.nix` dropped from Home-Desktop-Work,
  which is the same physical desktop as Home-Desktop. Home-Laptop-Work keeps TLP.
- **`system/security/sshd.nix`**: finding 7: the required `userSettings` argument removed. It was
  never supplied, and the first line of the module body to read it would have broken three
  machines. `authorizedKeys ? []` has a default so it cannot break, and the commented line below
  still refers to it, so it stays.
- **`system/app/libreOffice.nix`** and **`hosts/LiveUSB/liveusb.nix`**: finding 7: the unused
  `self` and `nixpkgs` arguments removed.
- **`system/security/mitmproxy_cert.nix`**: finding 4: now points at
  `/etc/mitmproxy/mitmproxy-ca-cert.pem` instead of `/home/nansus/.mitmproxy/…`. A CA inside the
  user's home can be rewritten by anything running as that user, which would make the whole system
  trust it. The comment above the option gives the one `install` command that puts the file there.
- **`system/hardware/opengl.nix`**: finding 14: the ROCm line moved out. Confirmed by evaluation:
  Home-Desktop reports `["clr"]`, the Intel Laptop reports `[]`, and Slave reports only its three
  Nvidia driver packages.
- **`system/base/fonts.nix`**: finding 16: `source-code-pro` added to the package list, so the
  `serif` and `sansSerif` entries that name "Source Code Pro" resolve instead of falling back; the
  duplicate `hack-font` entry removed. Each font that `defaultFonts` uses now carries a note above
  it saying where it is applied, in `.dotfiles/…/file` form.
- **`hosts/{Home-Desktop,Slave,Work/Home-Laptop-Work}/home.nix`**: finding 16: `serif`,
  `sansSerif` and `monospace` all now say `"FiraCode Nerd Font"`. The old values were wrong in two
  ways: "Fira Serif Nerd Font" does not exist at all, and the real family name has no space in
  "FiraCode": checked with `fc-scan` against `nerd-fonts.fira-code`, which reports
  `FiraCode Nerd Font`. So `sansSerif` and `monospace` were falling back too, along with
  `serif`.
- **The five `home.nix` files**: finding 20: their `programs.git` blocks removed now that the
  identity lives in `basics` / `workBasics`.
- **Keybinds**: finding 10: `$menu = wofi --show drun` became `rofi --show drun` on Home-Desktop,
  Slave, `Work/Home-Desktop-Work/.config/hypr/hyprland.conf` and
  `Work/Home-Laptop-Work/.config/hypr/UserConfigs/StartPrograms.conf`; wofi was never installed.
  Finding 12: `binde = ,Super+F12 / ,Super+F11` became `binde = , F6` and `binde = , F5` on
  Home-Desktop, Slave and the Work desktop. The modifier belongs in the first field, so the old
  lines never fired, and F9-F12 are already taken by the volume binds. F6 raises, F5 lowers, and
  the trailing comments on those lines still read correctly. Finding 13: the second `$mainMod, Z`
  bind deleted on Home-Desktop so Z stays on `togglefloating`, and the duplicate `$mainMod, P`
  bind deleted on Home-Desktop, Slave and both Work configs.

### Deleted: finding 17

- `system/hardware/nixos-hardware/` (81 files): a stale copy of a flake input.
- `hosts/Work/testing_Home-Laptop-Work/` (41 files): never named in `flake.nix`.
- Ten modules nothing referenced: `app/fhs_vscode.nix`, `app/mysql.nix`, `app/Zotero.nix` (which
  could not even evaluate: bare `jdk`), `base/emacs.nix`, `games/boot_to_steam_deck/`,
  `games/flatpak.nix`, `hardware/gaming_kenrel.nix`, `hardware/printing.nix`,
  `security/firejail.nix` with its profile directory, `security/gpg.nix`.
- `.bak/`, `system/security/mitmproxy.pac`, `hosts/Laptop/.config/direnvrc`.
- Nine empty `start_hyprland.sh` files and the `exec-once` lines that called them.

### Deleted: finding 8

Every backup, log and archive copy under the deployed `.config` trees: `old_hypr.bak/`,
`hypr.bak/`, `old_fastfetch/`, `fastfetch/additional_configs/`, `hypr/.new_UserConfigs/`, all
`*.bak`, `*.save`, `*.log`, `moved_*` and `*_hyprland.conf` files. 0 of the 172 remaining
`.config` files are now backups, down from 198 of 408.

### Finding 9: btop

`btop.conf` is renamed to `btop.conf.in` in all five host trees, and `basics` / `workBasics` gained
a `seedBtopConfig` activation step that copies it to `btop.conf` when that file is absent. This way
home-manager never owns `~/.config/btop/btop.conf`, so btop can write it on exit and a regular file
sitting there can never abort the next `home-manager switch`, which is what a plain
copy-over-the-symlink approach would have caused. Your theme choice and settings are preserved.

### Orphaned comments

Three comments now sit above nothing, because the statement they described was removed and the
brief says not to touch comments. Say the word and they go:

- `system/base/shells/zsh.nix`: `# update, upgrade easier to remember xd`, above where the two
  deleted aliases were.
- The five `home.nix` files: `#Enable git`, now that git is configured centrally.
- `hosts/Laptop/home.nix`: the two `#userName` / `#userEmail` lines that were inside the deleted
  `programs.git` block.
- The hypr `Execs.conf` files: `# Good tips from Vimjoyer or LibrePhoenix!` and
  `# Create shell command to run hyprland.conf`, above the deleted `start_hyprland.sh` calls.

### Left alone, needs your call

`hosts/Slave/.config/hypr/UserConfigs/Keybinds.conf` still binds `$mainMod + P` twice, to
`pseudo` on line 16 and to `exec, spotify` on line 23. Those are two different actions, and
"use Z version" did not tell me which one you want, so I removed only the exact duplicate.

### Verified

All six machine configurations and all five home configurations still evaluate to a derivation,
checked against the nixpkgs 26.05 and home-manager 26.05 sources in the local store with
`specialArgs` matching the new shape (`inputs` only, no `pkgs`). Spot checks confirm: TLP off on
Home-Desktop, Slave and the Work desktop and still on for both laptops; ROCm only on Home-Desktop;
dolphin present on all five; the work account on zsh; no `Home-Laptop` string left in
`programs.zsh.promptInit`; git identity resolving from the shared binding. Every relative `.nix`
import in the repo resolves. `nix flake check` still has not been run, for the git reason below.

## 2026-11-06: deployable Work hosts, a work account at gdm, Pentesting removed

Three things: the two hosts under `hosts/Work/` could not be evaluated at all, there was no way
to reach the work setup without a rebuild, and the Pentesting account was no longer wanted.

Existing comments were left byte-identical throughout. The only comments added are
`# ---- hostname ----` and `# ---- Users ----` banners inside `imports`, plus the prose notes in
the one new module, all in the same style as the rest of the folder.

### Added

- **`system/base/users/work_user.nix`** (new, 32 lines): defines `users.groups.nansus-work` and
  `users.users.nansus-work`, mirroring the `users.users.nansus` block in the host configs. Sets
  `shell = pkgs.zsh;` explicitly, because `system/base/shells/zsh.nix` only sets the shell for
  `nansus`. gdm needs no new option: it lists every normal user, so the work account shows up on
  the login screen on its own.
- **`changes.md`**: this file.
- **`AUDIT.md`**: the repo audit, re-checked against the state after these changes.

### Changed

- **`hosts/Work/Home-Desktop-Work/configuration.nix`** (+24 / -19)
  - Every `../../system/...` import became `../../../system/...`. The folder sits two levels under
    `hosts/`, so the old paths resolved to `hosts/system/...`, which does not exist. This is what
    made the host unbuildable.
  - `../../system/base/locale.nix` became `../../../system/base/locale/Netherlands_locale.nix`.
    `locale` is a folder, not a file, and Netherlands is what the counterpart `hosts/Home-Desktop`
    uses.
  - Added a `# ---- hostname ----` banner and `../../../system/base/hostnames/Home-Desktop.nix`,
    so the host is `NanSuS-Desktop` instead of booting as `nixos`. Same physical machine, so the
    same name as the counterpart.
  - Added a `# ---- Users ----` banner and the `work_user.nix` import.
  - `../../Home-Desktop/Desktop-hw.nix` on line 7 was left alone; it already resolved correctly.

- **`hosts/Work/Home-Laptop-Work/configuration.nix`** (+25 / -20)
  - Same import-depth fix, and `locale.nix` became `locale/Finnish_locale.nix` to match
    `hosts/Laptop`.
  - Added the `# ---- hostname ----` banner and `../../../system/base/hostnames/Laptop.nix` as a
    new line **above** the existing `#../../system/base/hostnames/Laptop.nix`, which was left
    as written and not uncommented.
  - Added the `# ---- Users ----` banner and the `work_user.nix` import.
  - `kernel.nix` on line 18 was left in place. It is an empty module, so it changes nothing.

- **`hosts/Laptop/configuration.nix`** (+3 / -0) and **`hosts/Home-Desktop/configuration.nix`**
  (+3 / -0): one blank line, a `# ---- Users ----` banner and the `work_user.nix` import. This is
  the point of the exercise: the work account has to exist on the system you are running
  for gdm to offer it. Nothing else in either file changed.

- **`flake.nix`** (+15 / -26)
  - Added a `workBasics` let-binding next to `basics`, same shape, with
    `home.username = "nansus-work"` and `home.homeDirectory = "/home/nansus-work"`. The existing
    `basics` hardcodes `nansus`, so the work configurations could not use it.
  - `"nansus@Home-Desktop-Work"` became `"nansus-work@Home-Desktop-Work"`, and
    `"nansus@Home-Laptop-Work"` became `"nansus-work@Home-Laptop-Work"`. Both now take
    `workBasics`. Their `home.nix` paths are unchanged.
  - Removed the `Pentesting = lib.nixosSystem { … };` block and the `"nansus@Pentesting"` block.
    The line `./system/base/shells/pentesting_env_zsh.nix` went with the first one; it named a
    file that never existed, which is what broke that output.

- **`system/base/shells/zsh.nix`** (+0 / -1): removed
  `alias .pt='cd ; cd .dotfiles/hosts/Pentesting/'`. The `.dotfiles` versus `.dotnet` comment above
  it belongs to the surrounding aliases and was left untouched.

### Deleted

- **`hosts/Pentesting/`**: the whole folder, 85 files.
- **`system/base/shells/pentesting_zsh.nix`**: the Pentesting shell module.

### How to use the work account

1. Rebuild the machine you are on, e.g. `sudo nixos-rebuild switch --flake .#Home-Laptop`. The
   `nansus-work` account now exists.
2. Give it a password once: `sudo passwd nansus-work`.
3. Apply its session once, logged in as that account:
   `home-manager switch --flake .#nansus-work@Home-Laptop-Work`.
4. From then on: close Hyprland to get back to gdm and pick the account. On the laptop that is
   `CTRL SHIFT, 0`; everywhere else, and inside both work sessions, it is `$mainMod, M`.

The separate `.#Home-Desktop-Work` and `.#Home-Laptop-Work` system configurations still exist and
still build, if you want the whole system swapped and not just the session.

### Known rough edges, not changed

1. `system/base/shells/zsh.nix:43` sources `~/.dotfiles/.../oh-my-zsh/custom/themes/zsh_theme`.
   The work account has no `~/.dotfiles`, so its prompt starts with a "no such file" line. A
   `[ -f … ] &&` guard on that line fixes it.
2. The Work `hypr/hyprpaper.conf` and `kitty/kitty.conf` files hardcode
   `/home/nansus/.dotfiles/system/wallpaper/…`. Read as `nansus-work` those point into another
   user's home, which is normally mode 700, so the wallpaper and kitty background will not load.
3. `hosts/Work/testing_Home-Laptop-Work/` still has the same broken import depth. It is not named
   anywhere in `flake.nix`, so it was left alone.

### Verified

`nix flake check` could not be run: `.dotfiles` is untracked inside the `/home/user/General` git
repository, so Nix refuses to read `flake.nix`, and the `nixos-hardware` input is not in the local
store. Instead, every configuration was evaluated directly against the nixpkgs 26.05 and
home-manager 26.05 sources already in the store, with the two flake inputs the leisure hosts use
stubbed out:

- All six machine configurations evaluate to a derivation: `Home-Desktop`, `Home-Desktop-Work`,
  `Home-Laptop`, `Home-Laptop-Work`, `Slave`, `LiveUSB`. The Work hosts came out as
  `nixos-system-NanSuS-Desktop` and `nixos-system-NanSuS-Laptop`, confirming the hostname imports.
- All five home configurations evaluate. Both work ones report
  `username = "nansus-work"`, `homeDirectory = "/home/nansus-work"`.
- On all four affected hosts, `users.users.nansus-work` comes out as a normal user with group
  `nansus-work`, home `/home/nansus-work`, shell zsh, and gdm enabled.
- Every relative `.nix` import in the repo was checked against the filesystem. The only ones that
  do not resolve are in `hosts/Work/testing_Home-Laptop-Work/`, which nothing imports.
- `grep -ri pentesting .` returns nothing.
