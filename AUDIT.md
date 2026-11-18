# AUDIT.md

Repo audit, last checked 2026-11-18.

**What this repo builds.** A NixOS flake building four machine configurations (`desktop`,
`laptop`, a headless `server`, a `live-usb` image) and five Home Manager configurations —
`nansus` on all three real hosts, `nansus-work` on the two leisure hosts. Dotfiles are a
three-layer merge of `common/.config`, that host's `.config`, and that user's `.config`
(`common/config-files.nix`); per-app packages are one home-manager module per app under
`system/app/`; kakoune and foot colors are generated from `common/palettes.nix`.

**Load assumed.** One person, a handful of personal machines, rebuilt by hand. No multi-user
service, no concurrency, no untrusted input — "scale" here means rebuild cost and closure size,
not races.

**Build state.** All four `nixosConfigurations` and all five `homeConfigurations` evaluate to a
derivation (`nix eval ... .drvPath`), checked against this machine's local store.

---

## Fixed

1. **`SUPER+V` ran a program that does not exist** —
   `common/.config/hypr/UserConfigs/Keybinds.conf`. The bind ran `protonvpn-gui`; the installed
   package is `protonvpn-app`. Now runs `protonvpn-app`.
2. **The server's launcher bind did nothing** — `hosts/server/.config/sway/config`. `$menu` was
   `rofi --show drun`; rofi only matches `-show`. Now `rofi -show drun -show-icons`, matching the
   hyprland hosts' bind, which now also uses `$menu` instead of repeating itself.
3. **Server screenshot names put the month in the minutes slot** — `date +%H-%m-%s` is now
   `date +%H-%M-%S`.
4. **The shared hyprland palette wrote colors hyprland cannot read** —
   `common/.config/hypr/UserConfigs/palette.conf`. Decimal `rgb(r, g, b)` is rejected by
   hyprland's `rgb()`, which wants a fixed-length hex string; `shadow { color_inactive =
   $color12 }` in `Decorations.conf` is a live, uncommented use. Rewritten in hex, matching the
   form `users/nansus/.config/hypr/UserConfigs/palette.conf` already used.
5. **Rainbow border script ran under `bash -x`** — `Execs.conf` traced every line into the
   hyprland log at every login for no benefit. Dropped `-x`; the `hyprctl keyword` call and the
   border animation are unaffected.
6. **The laptop's microphone indicator could never be styled** — its `pulseaudio#microphone`
   module used two CSS selectors that never matched anything (`#pulseaudio#microphone.source-muted`
   names two IDs in one selector, invalid CSS; `#microphone.source` names a node waybar does not
   create). Moved the laptop onto the desktop's working `custom/microphone` script module
   instead of patching the dead selectors; the script moved from the desktop's `.config` layer
   into `common/.config/hypr/scripts/` so both hyprland hosts have it as a fallback under either
   account's own copy. The two dead CSS rules are gone from all three style sheets.
7. **`nvidia-smi` ran once a second, forever** — the desktop and server waybar GPU module spawned
   a fresh `nvidia-smi`/`awk` pair every second. Now one long-lived `nvidia-smi -lms 1000`
   process per host, same 1-second refresh, with `restart-interval` to respawn it if the driver
   restarts.
8. **The server's kakoune/foot theme was two files joined into one** — `hosts/server/theme.nix`
   and `users/nansus/home.nix` both forced the same option with `lib.mkForce`; home-manager
   treats that as lines and joins rather than resolves them, so the rendered `account.kak` held
   both themes back to back. `hosts/server/theme.nix` is deleted; the server now takes the
   common theme, with each account's own override applying exactly as it does on the desktop.
9. **The server's terminal colors were generated and then ignored** — foot only loads
   `colors.ini` through an `include` line in `foot.ini`; no host-independent `foot.ini` existed,
   so the server had none at all. Added `hosts/server/.config/foot/foot.ini`.
10. **Six unused NixOS app modules** (`system/app/{dolphin,discord,spotify,FreeCAD,Qemu}.nix`,
    `system/games/prismlauncher.nix`) were imported nowhere; the same packages were separately
    listed in `users/nansus/home.nix`. Converted to per-app home-manager modules under
    `system/app/`, imported by `common/home.nix` (dolphin, discord, spotify, freecad, qemu — now
    shared by both accounts) or by `users/nansus/home.nix` (prismlauncher, kept account-specific).
11. **Three commented-out, unwanted virtualization modules deleted** —
    `system/app/{Docker,virt-manager,VirtualBox}.nix` and their commented import lines.
12. **Duplicate files deleted**: `hosts/server/.config/btop/themes/account.theme` (byte-identical
    to the shared theme, so it overrode nothing) and
    `hosts/live-usb/.config/fastfetch/moved_chesire_cat_with_text` (byte-identical to the common
    copy; `hosts/live-usb/configuration.nix` now points at the common file directly).
13. **Group memberships that pointed at groups no host creates** — `nansus` was in `vboxusers`
    and `libvirtd` in `common/system.nix`, but both creating modules were commented out
    everywhere (and are now deleted). Dropped both from `extraGroups`.
14. **`QT_QPA_PLATFORMTHEME` set twice** in both hyprland hosts' `ENV-Variables.conf` — `qt5ct`
    then `qt6ct`, the second silently winning. Removed the first.
15. **Window swallowing pointed at a terminal that is gone** — `swallow_regex = ^(kitty)$` in
    both hyprland hosts' `Settings.conf`, while the terminal is foot everywhere. Now `^(foot)$`.

## Accepted, not fixed

- **Logging in opens two terminals** — `StartPrograms.conf`'s `exec-once = $terminal &
  $terminal` starts foot twice on every hyprland login. Left as-is by choice.
- **`SUPER+E` (dolphin) and `SUPER+D` (discord) were inert for `nansus-work`** before fix 10;
  they now work, since both apps are shared. `SUPER+C` (`code`) stays inert on every account —
  no package installs an editor bound to that key — kept for uniform binds across hosts with
  different software installed.
- **`system/base/shells/oh-my-zsh/custom/themes/zsh_theme_v2`** sits unreferenced next to the
  theme `zsh.nix` actually falls back to. Left in place; under construction.
- **`system/base/terminator.nix`, `system/hardware/roccat.nix`,
  `system/security/{sshd,mitmproxy_cert}.nix`** stay as files, imported only behind a comment on
  the hosts that might want them — a stated convenience, not dead code.
- **The server's sway border colors stay red**, set directly in
  `hosts/server/.config/sway/colors` rather than through `common/palettes.nix`. This is the one
  remaining host-specific color override in the repo.

---

## Verdict

Healthy. All nine flake targets (four `nixosConfigurations`, five `homeConfigurations`) evaluate.
No sshd, firewall on, only `tailscale0` trusted — no meaningful attack surface for a single-user
box.

## Not checked

- The bodies of the waybar, fastfetch, kakoune, rofi and wallust config files — checked for
  duplicates and dead references, not whether every setting inside them is valid.
- Nothing was switched on real hardware; verification is `nix eval` against the local store plus
  targeted greps of installed binaries (rofi, waybar, hyprland) for the strings the failures in
  this audit depend on.
