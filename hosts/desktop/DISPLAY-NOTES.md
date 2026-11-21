# Desktop display notes: HDR, colour management and brightness

ASUS TUF Gaming VG34VQL1B on DP-3, Hyprland 0.55.4. Read this before changing
`hosts/desktop/.config/hypr/UserConfigs/Monitors.conf`, the `render { }` block in
`hosts/desktop/.config/hypr/UserConfigs/Settings.conf`, `system/hardware/ddc.nix`
or `common/.config/hypr/scripts/brightness.sh`.

Everything below was measured on this machine against Hyprland 0.55.4 and the official
VG34V series user guide. The open items at the end are open because they need a game,
the monitor's physical OSD, or a judgment call.

## The panel is the constraint

From the official specification table in the VG34V series user guide:

| Spec | Value |
| --- | --- |
| Brightness | 550 cd/m² typical, **550 cd/m² peak** |
| Display colours | 16.7M, **8 bit** |
| Intrinsic contrast | 4000:1, no local dimming |

Typical equals peak, so there is no HDR brightness headroom. HDR on this monitor changes
the tone curve and nothing else. The panel is also 8 bit, so `bitdepth = 10` produces a
10-bit framebuffer (`currentFormat: XBGR2101010`) that the monitor dithers back down. It
is harmless and it buys nothing; it stays only because nobody asked to remove it.

## Current configuration

`Monitors.conf` uses a `monitorv2` block with `cm = auto`, so `colorManagementPreset`
idles at `srgb` and HDR engages only for fullscreen HDR content. `sdrbrightness`,
`sdrsaturation`, `sdr_min_luminance` and `sdr_max_luminance` apply only while the output
is in HDR.

The laptop is deliberately different: `hosts/laptop/.config/hypr/UserConfigs/Monitors.conf`
keeps `cm, hdr` always on, because that panel has a backlight device and does not depend
on SDR mode for brightness control.

Brightness runs through `common/.config/hypr/scripts/brightness.sh`, bound to F5 and F6 in
`common/.config/hypr/UserConfigs/Keybinds.conf`. One script serves both hosts: a non-empty
`/sys/class/backlight` means `brightnessctl -c backlight`, an empty one means `ddcutil` over
DDC/CI. `system/hardware/ddc.nix` provides the i2c side.

## Hyprland facts that are easy to get wrong

- `sdr_min_luminance`, `sdr_max_luminance`, `min_luminance`, `max_luminance`,
  `max_avg_luminance`, `supports_hdr` and `supports_wide_color` exist **only** as
  `monitorv2` keys (`src/config/legacy/ConfigManager.cpp:572-582`). Putting any of them on
  a `monitor =` line is a parse error, and Hyprland then discards the **whole** rule: the
  screen silently falls back to its EDID default mode.
- A `monitorv2` block **replaces** any `monitor =` rule for the same output rather than
  merging with it (`src/config/shared/monitor/MonitorRuleManager.cpp:33-35` erases by name
  before appending). Mode, position and scale therefore have to live inside the block.
- `monitorv2` values cannot be changed at runtime. `hyprctl keyword 'monitorv2[DP-3]:sdrsaturation' 0.5`
  answers `ok` and does nothing, because the block is a special category applied only on a
  full config reload. A brightness keybind can never drive these keys.
- The inline `hyprctl keyword monitor "DP-3, ..."` form *does* apply at runtime, but it
  cannot carry `sdr_min_luminance`, so using it resets the black floor to the 0.2-nit
  default.
- `Hyprland --verify-config` validates key **names** inside `monitorv2` but not their
  **values**: a block containing `cm = bogus` returns `config ok`. Always confirm with
  `hyprctl reload` followed by `hyprctl monitors all`.
- `sdr_min_luminance` reaches the shader whenever the conversion is SDR to HDR
  (`src/render/Renderer.cpp:1912` gates on `needsSDRmod`), so it still works with
  `sdrbrightness` and `sdrsaturation` both at 1.0.

## DDC/CI: what works and what does not

The monitor answers on `/dev/i2c-8`, DRM connector `card1-DP-3`, ddcutil display 1,
serial `R2LMTF052411`.

- Reads always work, in every colour mode.
- Writes are **rejected while `colorManagementPreset` is `hdr`**. `ddcutil setvcp 10 30`
  returns `Verification failed for feature 10 / DDCRC_VERIFY` and the value does not move.
  Contrast (`0x12`) behaves the same way.
- Writes succeed under `srgb` and `wide`, confirmed by A/B on the same bus minutes apart.
- A brightness value written in SDR survives the switch into HDR, but it has **no visible
  effect** there: 10 against 70 looked identical by eye. In HDR the monitor drives its
  backlight from the HDR curve and ignores the register.
- Measured call cost: `--bus 8` 0.32s, `--sn <serial>` 1.03s, `--display 1` 1.15s. The
  script pins `--bus 8` for that reason and carries a `shortcut:` comment with the
  recovery command.

The user guide documents only two conditions that lock Brightness, and HDR is neither:
GameVisual **sRGB Mode** ("the Saturation, Skin Tone, Color Temp., Brightness, Contrast and
ASCR functions are not user-configurable") and **Blue Light Filter Level 4** ("The
Brightness function is not user-configurable"). Neither is active here, since writes work
the moment HDR is off. The DDC/CI toggle itself lives under **System Setup → OSD Setup →
DDC/CI** and is on.

## Open: does `cm = auto` really switch into HDR

Never observed. `colorManagementPreset` reads `srgb` at idle across six consecutive samples,
which is what the configuration wants, but the HDR half is untested.

1. Launch a game with `DXVK_HDR=1` and `ENABLE_HDR_WSI=1` in its own environment; neither is
   set globally.
2. While it is fullscreen, run `hyprctl monitors all | grep colorManagementPreset`.
3. `hdr` means `render:cm_auto_hdr` plus `experimental:wp_cm_1_2` are doing their job. `srgb`
   means the switch is not happening and the `sdr_*` keys in `Monitors.conf` are dead code.

Note that F5 and F6 are expected to do nothing during that game, because DDC writes are
blocked in HDR. The script drops the step silently.

## Open: the other HDR mode

The monitor has two HDR modes, ASUS Cinema HDR and ASUS Gaming HDR, selected in the OSD
under **Image → HDR**. Only one of them has been tested, and it blocks DDC writes. Switching
to the other by hand and re-running the write is a one-minute check:

```
ddcutil --bus 8 setvcp 10 70 && ddcutil --bus 8 getvcp 10
```

If that reports 70 instead of a `DDCRC_VERIFY` error, brightness control is possible inside
HDR and `cm = hdr` becomes viable again for this host.

## Open: dimming while in HDR

If HDR ever needs to be always on here and brightness must still change, `hyprsunset --gamma
<percent>` is the only remaining route. It applies through `hyprland-ctm-control-v1`, so it
dims the whole output including HDR content, but it is a digital dim rather than a backlight
change, and its interaction with `direct_scanout = true` is untested. Not installed.
