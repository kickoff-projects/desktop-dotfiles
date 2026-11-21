# Audit findings to fix

From the 2026-11-21 ponytail audit of `flake.nix` and the files each user and host import. Finding 1 (live-usb empty root password) and finding 2 (nansus-work account on the server) are not being fixed. These three are.

## 1. GUI apps installed on the headless server account

**File:** `common/home.nix:17-23`

**What this is:** `common/home.nix` is the home-manager module shared by every account on every host. Its `imports` list is:

```nix
imports = [
  ../system/app/dolphin.nix
  ../system/app/discord.nix
  ../system/app/spotify.nix
  ../system/app/freecad.nix
  ../system/app/qemu.nix
];
```

Because this file has no host check, these five imports land on `nansus@server` exactly as they do on `nansus@desktop` and `nansus@laptop` and the two `nansus-work@*` configurations.

**Problem:** `flake.nix` describes the server as a "Headless ML / dev box, runs sway rather than hyprland" (`hosts/server/configuration.nix` comment). It has no desktop session, window manager chrome, or display manager that a file manager (`dolphin`), a chat client (`discord`), a music client (`spotify`), or CAD software (`freecad`) could ever be opened in. `qemu` is at least plausibly useful for a dev box, but the other four are dead weight: built, stored, and kept up to date on every `home-manager switch` for a machine that can never run them.

**Fix:** Move the four GUI-only imports out of `common/home.nix` into the two account files that actually run a graphical session:

- `users/nansus/home.nix` — add `../../system/app/dolphin.nix`, `../../system/app/discord.nix`, `../../system/app/spotify.nix`, `../../system/app/freecad.nix` to its existing `imports = [ ../../system/app/prismlauncher.nix ];` list.
- `users/nansus-work/home.nix` — add the same four imports (it currently has no `imports` line at all, so this is new).
- Leave `qemu.nix` in `common/home.nix` if it is wanted on the server for VM-based dev work, or move it alongside the others if not.

This keeps every package the same for `nansus@desktop`, `nansus@laptop`, `nansus-work@desktop`, and `nansus-work@laptop` (same five packages, just declared in two files instead of one), and removes four unused packages from the server's closure.

**If left unfixed:** Disk space and rebuild time on the server keep going to five desktop packages that have no window manager to run in.

---

## 2. `nixpkgs.config.allowUnfree` is set twice for the same host

**Files:** `common/system.nix:18` (import) and `common/system.nix:52` (direct setting); `system/base/unfree_software.nix` (whole file)

**What this is:** `common/system.nix` imports `system/base/unfree_software.nix`:

```nix
imports = [
  ...
  ../system/base/unfree_software.nix
  ...
];
```

`system/base/unfree_software.nix`'s entire body is:

```nix
{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
}
```

A few lines further down in the same file, `common/system.nix` sets the identical option again, directly:

```nix
# Allow unfree software
nixpkgs.config.allowUnfree = true;
```

**Problem:** Both lines are active on every host that imports `common/system.nix` (desktop, laptop, server). They agree today, so nothing is broken, but the setting now has two sources of truth that have to be kept in sync by whoever edits this file next. If one is ever changed without the other (e.g. someone flips the inline one to `false` to test something and forgets the imported module still forces `true`), the result is confusing rather than a clean override.

**Fix:** Delete `system/base/unfree_software.nix` and remove its import line from `common/system.nix`. Keep only the inline `nixpkgs.config.allowUnfree = true;` that is already in `common/system.nix`. No behavior changes — this removes a one-line file and one import line.

**If left unfixed:** The same boolean lives in two places with no code-level link between them, so a future edit can silently diverge.

---

## 3. A code comment points at a file that does not exist

**File:** `common/palettes.nix:3-4`

**What this is:** The file header comment reads:

```nix
# Per-theme color data for the surfaces that are pure 16-slot palettes:
# kakoune (base16-shaped already) and foot. Rendered into real files by
# common/lib/render-kak.nix and common/lib/render-foot-colors.nix - see
# common/home.nix and hosts/Server/theme.nix for where each theme is picked.
```

**Problem:** There is no `theme.nix` under any host directory (`hosts/desktop`, `hosts/laptop`, `hosts/server`, `hosts/live-usb`) — confirmed by searching the whole `hosts/` tree. The casing is also wrong: the real directory is `hosts/server` (lowercase), not `hosts/Server`. `flake.nix`'s own `homeFor` function (`flake.nix:114-134`) does look for an optional `hostDir/theme.nix` and would wire one up if it existed, but none of the three real hosts has ever had one — every account currently gets its theme from `common/home.nix`'s `mkDefault` plus whatever the user's own `home.nix` overrides. A reader who goes looking for `hosts/Server/theme.nix` to understand how the server's theme is chosen will not find it and will not find an explanation of why not.

**Fix:** Either:
- (a) write `hosts/server/theme.nix` if a server-specific theme is actually wanted, matching the pattern `homeFor` already supports, or
- (b) remove the dangling `hosts/Server/theme.nix` reference from the comment, since no host currently uses that mechanism.

The simplest fix that changes no behavior is (b): drop the trailing clause so the comment reads `...see common/home.nix for where each theme is picked.`

**If left unfixed:** Anyone tracing "where is the server's theme set" from this comment loses time looking for a file, with the wrong path and wrong case, that was never created.
