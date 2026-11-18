Personal NixOS flake for four machines: a desktop, a laptop, a headless server, and a live USB
image. Rebuilt and rsynced by hand — no install scripts.

( Heavy lift and inspiration from JaKooLit's setup, in limited amount. Gskartwii has given a lot
of good advice getting things working — big mcthankies from mcspankies. )

## Layout

Three layers, one more than a single-machine setup needs, since there are four machines here:

- `common/` — everything every machine and every account shares: the NixOS module list
  (`common/system.nix`), the home-manager base (`common/home.nix`), the per-app home-manager
  modules (`common/apps/`), and the default (rainbow) dotfiles under `common/.config`.
- `hosts/<name>/` — one machine. `configuration.nix` + `hardware.nix`, plus a `.config` with
  only what's genuinely different on that box (monitor layout, waybar's module list, a palette
  override). The directory name is the `nixosConfigurations` attribute and the home-manager
  suffix, e.g. `hosts/laptop` builds `.#laptop` and `nansus@laptop`.
- `users/<name>/` — one account's home-manager module and, if it switches the theme, its own
  `.config` override.

A file under `hosts/<host>/.config/foo` or `users/<name>/.config/foo` replaces the file of the
same path from `common/.config/foo`. `common/config-files.nix` does the merging; `common/home.nix`
is where the three layers get combined for a given account.

**Color schemes are per account, not per machine.** `nansus` is rainbow on every host it logs
into — desktop, laptop, and the server. `nansus-work` is rainbow too, except its kakoune, which
is a black/neon variant (`common/palettes.nix`'s `neon_rainbow`) — that is the one surface the
work account overrides.

Every themed surface works off the same idea — the shared config always references a fixed
filename (`colors.css`, `account.kak`, `account.theme`, ...), and whichever layer provides that
filename wins — but two different mechanisms provide it:

- **waybar, hyprland borders, btop, rofi**: a plain file per theme (`colors.css`,
  `account.theme`, `account.rasi`, `palette.conf`). To add a scheme here, write that same set of
  fixed-name files in a new layer.
- **kakoune and foot**: generated from `common/palettes.nix`. Both are already 16-slot color
  tables (kakoune's is a base16 scheme; foot's is a terminal palette), so a new theme is
  sixteen-ish hex values added to `palettes.nix`, not a hand-copied file —
  `common/lib/render-kak.nix` and `render-foot-colors.nix` hold the shared template. A layer
  overrides either by setting `xdg.configFile."kak/colors/account.kak".text` (or
  `"foot/colors.ini".text`) with `lib.mkForce`, the way `users/nansus-work/home.nix` does.
  `hostDir/theme.nix` is picked up automatically if a host has one, the same optional-import
  pattern as `hostDir/.config` — no host currently uses it.

**Per-app packages live under `common/apps/`**, one file per app (`dolphin.nix`, `discord.nix`, …),
each a small home-manager module setting `home.packages`. `common/home.nix` imports the ones
every account gets; an account's own `home.nix` imports anything that should stay
account-specific (`prismlauncher`, today, under `nansus` only).

**claude-code's config is a fourth surface, under `~/.claude` rather than `~/.config`.**
`common/claude-files.nix` is the same per-file symlink trick as `config-files.nix` but aimed at
`home.file`, with two layers instead of three: `common/.claude` for everything shared —
`CLAUDE.md` and `themes/neon-theme.json` — and `users/<name>/.claude` on top of it for anything
one account wants differently.

`~/.claude/settings.json` is deliberately **not** managed. Claude rewrites it itself on every
`/config`, `/model` or theme change, so a read-only store symlink would make those silently fail.
Selecting the theme is therefore one manual line per machine — add
`"theme": "custom:neon-theme"` to `~/.claude/settings.json`, or pick it in `/config`.

**The server runs sway, not hyprland** — see `hosts/server/.config/sway/`. Everything
hyprland-specific (blur, shadows, animations, `hyprctl`) simply doesn't exist there. Its window
borders are red, set directly in `hosts/server/.config/sway/colors` rather than through
`common/palettes.nix` — the one host-specific color override left in the repo; every other theme
surface on the server takes the common rainbow.

## Rebuilding

```sh
sudo nixos-rebuild switch --flake ~/desktop-dotfiles#<desktop|laptop|server>
home-manager switch --flake ~/desktop-dotfiles#<nansus|nansus-work>@<host>
```

(the `nrs`/`hms` functions from `system/base/shells/zsh.nix` do the same, taking the host as an
argument — either `<host>` or `<user>@<host>` — so there's no risk of rebuilding the wrong
machine.)

live-usb builds straight from `nix build .#nixosConfigurations.live-usb.config.system.build.isoImage`.
