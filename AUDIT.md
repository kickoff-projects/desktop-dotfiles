# AUDIT.md

Repo audit, last re-checked on 2026-11-06 after the work recorded in `changes.md`. Numbering is
kept from the first pass, so "fix 11" still points at the same thing.

**What this repo does.** A NixOS flake that builds four machine configurations (desktop, laptop, a
headless Server, a live USB image) and five Home Manager user configurations: `nansus` on all
three real hosts, and `nansus-work` picked at the gdm login screen on the two leisure hosts, as a
separate account on the same machine. As of the 2026-11-14 refactor (`changes.md`),
each machine's `configuration.nix` imports the shared `common/system.nix` plus its own deltas, and
each account's dotfiles are a three-layer merge of `common/.config`, that host's `.config`, and
that user's `.config` (`common/config-files.nix`). The description below this point is the
pre-refactor state; see `changes.md` for what moved.

**Load assumed.** One person, a handful of personal machines, rebuilt by hand. No multi-user
service and no concurrency, so "scale" findings are about rebuild cost and closure size.

**Build state.** All six machine configurations and all five home configurations evaluate to a
derivation, verified against the nixpkgs 26.05 and home-manager 26.05 sources in the local store.
See the note at the end about `nix flake check`.

---

## Still open

**11. Logging in opens two terminals**: `common/.config/hypr/UserConfigs/StartPrograms.conf:6-7`

- What this is: the autostart list for the desktop session.
- Problem: `exec-once = [workspace 1 silent] $terminal` appears twice in a row, so two foot
  windows stack on workspace 1 at every login.
- Fix: delete one of the two lines.
- If we skip it: a window to close every login.
- Status after the 2026-11-14 refactor (see `changes.md`): left as-is on purpose. It moved
  from a per-host file into `common/.config`, so it now affects both leisure hosts identically,
  but the fix itself was out of scope for that round.

---

## Applied

Each of these was fixed on 2026-11-06; `changes.md` records exactly what changed and why.

- **1.** The `upgrade` and `update` aliases that hardcoded `.#Home-Laptop` are gone. `hms` and
  `nrs` remain and take the host as an argument, so no alias can rebuild the wrong machine.
- **2.** The two Work hosts' import paths were corrected, so every machine configuration builds.
- **3.** The pentesting shell that sourced a `.nix` file went with the Pentesting host.
- **4.** `mitmproxy_cert.nix` now trusts `/etc/mitmproxy/mitmproxy-ca-cert.pem` instead of a path
  inside the user's home.
- **5.** `pkgs` removed from every `specialArgs` block, so `nixpkgs.config` and `nixpkgs.overlays`
  behave the same on all six machines.
- **6.** The duplicate `zsh.nix` imports in `flake.nix` are gone, and the two Work hosts now take
  the new, smaller `system/base/shells/work_zsh.nix`.
- **7.** The module arguments nothing supplied (`userSettings`, `self`, `nixpkgs` and `system`)
  are deleted, so no future edit can trip over them.
- **8.** Every backup, log and archive copy under the deployed `.config` trees is deleted. 0 of 172
  `.config` files are now backups, down from 198 of 408.
- **9.** `btop.conf` ships as `btop.conf.in` and is seeded by a `home.activation` step, so btop can
  write its own settings and home-manager never finds a stray file in the way.
- **10.** `kdePackages.dolphin` is installed via the new `system/app/dolphin.nix`, and every
  `$menu = wofi` became `rofi`, which is what was installed.
- **12.** The brightness binds are `binde = , F6` (raise) and `binde = , F5` (lower), now in a
  Brightness section of the shared `Keybinds.conf` so every host has them. The old `,Super+F12`
  form put the modifier in the key field and never fired.
- **13.** Moot as a defect: all five hosts now share the Laptop's `Keybinds.conf`, which has no
  duplicate binds. The Slave `$mainMod, P` clash between `pseudo` and `exec, spotify` went with
  the old per-host file.
- **14.** ROCm is gone entirely. It was first split into an AMD-only module, then deleted once it
  turned out the desktop has Intel graphics too, so no machine here can use it. `opengl.nix` now
  only enables `hardware.graphics`.
- **15.** TLP is no longer imported on Home-Desktop, Slave or the Work desktop. `CPU_MAX_PERF_ON_AC
  = 90` was holding the ML box below full speed. Both laptops keep it.
- **16.** Iosevka was removed at your request, so `monospace` now names `"FiraCode Nerd Font"`.
  `source-code-pro` is installed so the "Source Code Pro" entries resolve, the duplicate
  `hack-font` is gone, and the three `home.nix` files now say `"FiraCode Nerd Font"`, the real
  family name per `fc-scan`, which fixes `sansSerif` and `monospace` as well as `serif`. Each
  font `defaultFonts` uses carries a note saying where it is applied.
- **17.** The vendored `nixos-hardware` copy, `testing_Home-Laptop-Work`, ten never-imported
  modules, `.bak/`, `mitmproxy.pac`, the dead `direnvrc` and nine empty scripts are all deleted.
  The repo went from 516 files to 263.
- **20.** `ncgo` uses `-d`, and the git identity lives once in the shared `basics` / `workBasics`
  bindings in the current `settings.user` spelling.

Fixed on 2026-11-14, as part of the shared-base/color-scheme refactor (`changes.md`):

- **18.** `flake-utils` and `sops-nix` are gone from `flake.nix` entirely: neither input nor any
  `sops-nix.nixosModules.sops` module reference remains. Re-adding `sops-nix` once secrets are
  managed is two lines, same as before.
- **19.** Closed by removing the service, with no keys declared: `system/security/sshd.nix`
  stays as a file, but its import is commented out on every host (`hosts/Home-Desktop`,
  `hosts/Home-Laptop`, `hosts/Server`), matching the repo's existing "commented are usually
  convenient to have" convention. The headless Server now has no remote access and is rebuilt at
  the machine. That trade was made on purpose.
- **22.** The shared `Keybinds.conf` binds stayed uniform on purpose, per instruction: "all hosts
  should have the same binds for keys for ease of use even if they haven't gotten yet the same
  software installed." `playerctl` is now installed via `common/home.nix`, so the four
  `XF86Audio` binds work everywhere; the rest (zen, protonvpn-gui, code, hyprshot, discord, steam)
  stay inert on hosts without the matching program, which is the accepted cost of uniformity.
  The Work hosts this finding named no longer exist (see `changes.md`), and `screen_shot.nix`'s
  hyprshot binds don't apply to the Server at all now that it runs sway. It gets its own
  grim+slurp binds in `hosts/Server/.config/sway/config` instead.

The rofi theme's hardcoded `/nix/store/...-rofi-1.7.5+wayland3/.../Arc-Dark.rasi` path (found
during the same refactor, never a numbered finding here) is also gone. `rofi/config.rasi` now
points at a repo-carried `account.rasi`, themed per account like everything else.

---

## Not findings

Six modules are referenced only from commented-out import lines:
`app/Docker.nix`, `app/virt-manager.nix`, `app/VirtualBox.nix`, `base/terminator.nix`,
`hardware/roccat.nix` and `security/mitmproxy_cert.nix`. `hosts/Laptop/configuration.nix:5` says
why: *"Commented are usually convenient to have in some situations."* That is a stated decision,
so they are kept. The first pass wrongly listed four of them as dead and missed three that really
were; the corrected list is in finding 17.

Five smaller items are left out of the numbering on purpose: the `gamemode` package listed next
to the module that already installs it, the byte-identical copies of `smooth_RainbowBorder.sh` run
with `bash -x`, the trailing commas in `Monitors.conf:5-6`, the `allowUnfreePredicate` in
`app/discord.nix:4` that `allowUnfree = true` makes unreachable, and the deprecated
`programs.vscode.extensions` spelling in three `home.nix` files.

---

## Verdict

Healthy. Nothing open can break a rebuild or take a machine down. **11** is the one remaining
one-line preference call; **18**, **19** and **22** were closed in the 2026-11-14 refactor.

## Not checked

- `testing_stuff_-beware-/`: skipped on purpose; its own README says to stay out, and the flake
  does not reference it. 880 lines.
- The bodies of the waybar, fastfetch, kakoune, rofi and wallust config files. Checked which were
  duplicates or backups, not whether each setting is valid.
- `nix flake check` and `nixos-rebuild` were not run. `.dotfiles` is untracked inside the
  `/home/user/General` git repository, so Nix refuses to read `flake.nix`
  (*"Path 'main_environment/.dotfiles/flake.nix' … is not tracked by Git"*), and the
  `nixos-hardware` input is not in the local store. Every configuration was instead evaluated
  directly against the nixpkgs 26.05 and home-manager 26.05 sources already in the store, with the
  cursor-theme and zen-browser inputs stubbed. To run the real check:
  `git -C /home/user/General add main_environment/.dotfiles && nix flake check`.
