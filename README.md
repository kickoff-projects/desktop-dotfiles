Nothing too fancy here, just trying to upkeep couple of my computers and at the same time trying to learn new
things regarding servers, programming and in general just about linux and nixos in particular. But please do take a look
of the configs if you happen to enjoy any stylistic implementations. 😎  Also don't mind me having this as my 
artistic canvas that might be messy at times but if ever need be I'll clean it up. My goal is to have clean code that is
easy to use but comments that might end up rambling way too extensively for no apparent reason. XD ALso worth mentioning, 
if push is made with commit message like "yeah" or "yuh" it's most likely been removal of unnessecary # or corrrected 
mispelling somewhere. 

Also, no install scripts here, at the moment it's rsync or nothing. 🥹

( This repo has gotten heavy lift and inspiration from JaKooLit's setup but only in limited amount of the
  full functionality he has made. Also multiple times when I have felt like a puppy left in a rain 
  when I've been trying to get some functionality working for days or weeks, Gskartwii has given a lot of good
  advice and explanation of what is going on, big mcthankies from mcspankies! )

## Layout

Three layers, same idea as `/srv/nixos-vm-config` but with one more layer since
there are four machines here instead of one:

- `common/` - everything every machine and every account shares: the NixOS
  module list (`common/system.nix`), the home-manager base (`common/home.nix`),
  and the default (rainbow) dotfiles under `common/.config`.
- `hosts/<name>/` - one machine. `configuration.nix` + `hardware.nix`, plus a
  `.config` with only what's genuinely different on that box (monitor layout,
  waybar's module list, a palette override). The directory name is the
  `nixosConfigurations` attribute and the home-manager suffix, e.g.
  `hosts/Home-Laptop` builds `.#Home-Laptop` and `nansus@Home-Laptop`.
- `users/<name>/` - one account's home-manager module and, if it switches the
  theme, its own `.config` override.

A file under `hosts/<host>/.config/foo` or `users/<name>/.config/foo` replaces
the file of the same path from `common/.config/foo` - same mechanism as the
VM config's `common` vs `users` layers, extended with the host layer in the
middle. `common/config-files.nix` does the merging; `common/home.nix` is
where the three layers get combined for a given account.

**Color schemes are per account, not per machine.** `nansus` is rainbow
everywhere it logs in - Home-Desktop, Home-Laptop, and the Server, where it
gets picked up by `hosts/Server`'s red override instead. `nansus-work` is
rainbow too, except its kakoune, which is red - that's the one surface the
work account overrides.

Every themed surface works off the same idea - the shared config always
references a fixed filename (`colors.css`, `account.kak`, `account.theme`,
...), and whichever layer provides that filename wins - but two different
mechanisms provide it:

- **waybar, hyprland borders, btop, rofi**: a plain file per theme
  (`colors.css`, `account.theme`, `account.rasi`, `palette.conf`). To add a
  scheme here, write that same set of fixed-name files in a new layer.
- **kakoune and foot**: generated from `common/palettes.nix`. Both are
  already 16-slot color tables (kakoune's is a base16 scheme; foot's is a
  terminal palette), so a new theme is sixteen-ish hex values added to
  `palettes.nix`, not a hand-copied file - `common/lib/render-kak.nix` and
  `render-foot-colors.nix` hold the shared template. A layer overrides
  either by setting `xdg.configFile."kak/colors/account.kak".text` (or
  `"foot/colors.ini".text`) with `lib.mkForce`, the way
  `users/nansus-work/home.nix` and `hosts/Server/theme.nix` do -
  `hostDir/theme.nix` is picked up automatically if a host has one, the
  same optional-import pattern as `hostDir/.config`.

**The Server runs sway, not hyprland** - see `hosts/Server/.config/sway/`.
Everything hyprland-specific (blur, shadows, animations, `hyprctl`) simply
doesn't exist there; the red theme uses sway's own `client.focused` colors
file instead of a palette.conf.

## Rebuilding

```sh
sudo nixos-rebuild switch --flake .#<Home-Desktop|Home-Laptop|Server>
home-manager switch --flake .#<nansus|nansus-work>@<host>
```

(the `nrs`/`hms` aliases from `system/base/shells/zsh.nix` do the same,
taking the host as an argument so there's no risk of rebuilding the wrong
machine.)

LiveUSB builds straight from `nix build .#nixosConfigurations.LiveUSB.config.system.build.isoImage`.
