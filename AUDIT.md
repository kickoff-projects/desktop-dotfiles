# AUDIT.md

Repo audit, last re-checked on 2026-11-06 after the work recorded in `changes.md`. Numbering is
kept from the first pass, so "fix 11" still points at the same thing.

**What this repo does.** A NixOS flake that builds six machine configurations (desktop, laptop, an
ML box called "Slave", two Work variants, a live USB image) and five Home Manager user
configurations — `nansus` on the three leisure hosts, and a `nansus-work` account picked at the gdm
login screen for the two Work ones. Each machine's `configuration.nix` picks modules out of
`system/`, and each `home.nix` copies that host's `.config` folder into the user's home.

**Load assumed.** One person, a handful of personal machines, rebuilt by hand. No multi-user
service, no concurrency. So "scale" findings are about rebuild cost and closure size, not races.

**Build state.** All six machine configurations and all five home configurations evaluate to a
derivation, verified against the nixpkgs 26.05 and home-manager 26.05 sources in the local store.
See the note at the end about `nix flake check`.

---

## Still open

**11. Logging in opens two terminals** — `hosts/Home-Desktop/.config/hypr/UserConfigs/StartPrograms.conf:6-7`

- What this is: the autostart list for the desktop session.
- Problem: `exec-once = [workspace 1 silent] $terminal` appears twice in a row, so two kitty
  windows stack on workspace 1 at every login.
- Fix: delete one of the two lines.
- If we skip it: a window to close every login.

**18. Two flake inputs are downloaded and never used** — `flake.nix:24,61`

- What this is: `flake-utils` and `sops-nix`.
- Problem: `flake-utils` is listed, named in the outputs function, and used nowhere.
  `sops-nix.nixosModules.sops` is added to all five machines without a single `sops.*` option set
  anywhere. Both are pinned in `flake.lock`, fetched on every `nix flake update`, and evaluated on
  every rebuild.
- Fix: remove `flake-utils` entirely. Leave `sops-nix` out until secrets are actually managed — the
  comment at `flake.nix:57-60` says that has not happened yet, and re-adding it later is two lines.
- If we skip it: two dependencies to update and audit that buy nothing.

**19. SSH is on, on three machines, with no keys declared** — `system/security/sshd.nix`

- What this is: incoming SSH on port 5445, imported by Home-Desktop, Laptop and Slave.
- Problem: password login is correctly off, so this is a lockout problem rather than an exposure
  one. The line that would install a key is commented out, so the only way in is a hand-placed
  `~/.ssh/authorized_keys` that this repo does not track. Reinstall a machine from the flake and it
  comes up listening with no way to log in. `openFirewall` defaults to true, so the port is open on
  the LAN either way.
- Fix: put the public keys in `users.users.nansus.openssh.authorizedKeys.keys` — public keys are not
  secrets.
- If we skip it: the headless Slave box is one reinstall away from needing a keyboard.

**22. Binds in the shared keybind file point at programs some hosts lack**

- What this is: `UserConfigs/Keybinds.conf` is now one shared file on all five hosts.
- Problem: a few binds name programs that are only installed on some of them. `$mainMod, F` /
  `CTRL SHIFT, F` (zen) and `$mainMod, V` (protonvpn-gui) work on the Laptop only; `$mainMod, C`
  (code) works everywhere except the Laptop, whose vscode is commented out; `CTRL SHIFT, X/A/S`
  (hyprshot) needs `screen_shot.nix`, which Slave and both Work hosts do not import; `$mainMod, D`
  and `$mainMod, S` have no discord or steam on the Work hosts; and the four `XF86Audio` media
  binds call `playerctl`, which is installed nowhere.
- Fix: either install the missing programs on the hosts that should have them, or drop the binds you
  do not want shared. Both are a preference, which is why nothing was changed.
- If we skip it: those keys do nothing on those hosts, silently.

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
- **7.** The module arguments nothing supplied — `userSettings`, `self`, `nixpkgs` and `system` —
  are deleted, so no future edit can trip over them.
- **8.** Every backup, log and archive copy under the deployed `.config` trees is deleted. 0 of 172
  `.config` files are now backups, down from 198 of 408.
- **9.** `btop.conf` ships as `btop.conf.in` and is seeded by a `home.activation` step, so btop can
  write its own settings and home-manager never finds a stray file in the way.
- **10.** `kdePackages.dolphin` is installed via the new `system/app/dolphin.nix`, and every
  `$menu = wofi` became `rofi`, which is what was actually installed.
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
  `hack-font` is gone, and the three `home.nix` files now say `"FiraCode Nerd Font"` — the real
  family name per `fc-scan`, which also fixes `sansSerif` and `monospace`, not just `serif`. Each
  font `defaultFonts` uses carries a note saying where it is applied.
- **17.** The vendored `nixos-hardware` copy, `testing_Home-Laptop-Work`, ten never-imported
  modules, `.bak/`, `mitmproxy.pac`, the dead `direnvrc` and nine empty scripts are all deleted.
  The repo went from 516 files to 263.
- **20.** `ncgo` uses `-d`, and the git identity lives once in the shared `basics` / `workBasics`
  bindings in the current `settings.user` spelling.

---

## Not findings

Six modules are referenced only from commented-out import lines:
`app/Docker.nix`, `app/virt-manager.nix`, `app/VirtualBox.nix`, `base/terminator.nix`,
`hardware/roccat.nix` and `security/mitmproxy_cert.nix`. `hosts/Laptop/configuration.nix:5` says
why — *"Commented are usually convenient to have in some situations."* That is a stated decision,
so they are kept. The first pass wrongly listed four of them as dead and missed three that really
were; the corrected list is in finding 17.

Five smaller items are deliberately left out of the numbering: the `gamemode` package listed next
to the module that already installs it, the byte-identical copies of `smooth_RainbowBorder.sh` run
with `bash -x`, the trailing commas in `Monitors.conf:5-6`, the `allowUnfreePredicate` in
`app/discord.nix:4` that `allowUnfree = true` makes unreachable, and the deprecated
`programs.vscode.extensions` spelling in three `home.nix` files.

---

## Verdict

Healthy. Nothing open can break a rebuild or take a machine down. **11** and **21** are one-line
preference calls, **18** removes two dependencies, and **19** is worth doing before the next
reinstall of the headless box.

**Lean: about -40 lines and -2 dependencies still possible**, out of 263 files today.

## Not checked

- `testing_stuff_-beware-/` — skipped on purpose; its own README says to stay out, and the flake
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
