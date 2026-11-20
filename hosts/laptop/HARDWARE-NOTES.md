# Laptop hardware notes

Lenovo Legion 16ITHg6. Read this before changing anything under `hosts/laptop/`,
`system/hardware/power.nix` or `system/hardware/nvidia_prime_power.nix`.

Everything here was worked out by evaluating `nixosConfigurations.laptop` from the
**desktop**, not by running it on the laptop. The open items below are open precisely
because they cannot be settled without the machine in hand.

## Open: hibernate, and the better upower action

`services.upower.criticalPowerAction` is `"PowerOff"` in `system/hardware/power.nix`.
upower's own default is `HybridSleep`, which is the nicer behaviour - it saves the session
instead of dropping it - but it needs working hibernate, and hibernate is not configured:
`boot.resumeDevice` is `""` even though `hosts/laptop/hardware.nix` declares a swap
partition (`/dev/disk/by-uuid/12a39c00-399d-44d2-91e6-3b731defcc4a`).

To enable it, on the laptop:

1. `free -h` and `swapon --show`. Hibernate needs swap at least the size of RAM; if the
   swap partition is smaller, stop here and leave `PowerOff` alone.
2. Set `boot.resumeDevice = "/dev/disk/by-uuid/12a39c00-399d-44d2-91e6-3b731defcc4a";`
   (same UUID as `swapDevices` in `hardware.nix`).
3. `nixos-rebuild switch --flake .#laptop`, then `systemctl hibernate` and confirm it
   actually resumes - with nvidia in the picture this is the step that fails.
   `hardware.nvidia.powerManagement.enable = true`
   (`system/hardware/nvidia_prime_power.nix`) is what preserves VRAM across it.
4. Only once that works: `services.upower.criticalPowerAction = "HybridSleep";`

## Open: on-device checks never run

Each of these was asserted from eval only and needs confirming on the machine. Fix the
config, not this file, when one of them comes back wrong.

- `cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status` - should read `suspended`
  at idle. If it never does, `hardware.nvidia.powerManagement.finegrained` is not taking
  effect, or something is holding the dGPU awake.
- `cat /sys/bus/pci/devices/0000:01:00.0/power/autosuspend_delay_ms` - waybar's
  `custom/nvidia` poll interval (`hosts/laptop/.config/waybar/config.jsonc`, currently
  10s) must stay **above** this, or the poll resets the autosuspend timer and keeps the
  dGPU awake by itself.
- `nvidia-smi` process list - if Hyprland itself appears as a client, the compositor is
  rendering on the dGPU. Pin it to the iGPU with
  `AQ_DRM_DEVICES=/dev/dri/by-path/pci-0000:00:02.0-card` in
  `hosts/laptop/.config/hypr/UserConfigs/ENV-Variables.conf`.
- `systemctl status nvidia-powerd` - `dynamicBoost.enable` is on; the daemon fails to
  start where the firmware does not support it, which is harmless but means the setting
  is doing nothing.
- `dmesg | grep -i legion` - `legion_laptop` is force-loaded via `boot.kernelModules`; it
  refuses to load on a chassis it does not recognise.
- `cat /sys/firmware/acpi/platform_profile_choices` - TLP's `PLATFORM_PROFILE_ON_AC/BAT`
  need this node. Compare with `legion_laptop` loaded and with it commented out; in-tree
  `ideapad_laptop` provides it on some Legions, in which case the out-of-tree module is
  not what makes those two TLP settings work.
- `tlp-stat -b` - `START/STOP_CHARGE_THRESH_BAT0 = 75/80`. Legions often expose only
  `conservation_mode` rather than arbitrary thresholds, in which case those two lines are
  inert and should go.
- `tlp-stat -p` - confirms the EPP that actually landed.
  `CPU_ENERGY_PERF_POLICY_ON_BAT` was `"balance"`, which is not one of the five strings
  `intel_pstate` accepts; it is now `balance_power`.
- `ls /sys/class/backlight` - waybar's `backlight` module is pinned to `intel_backlight`.
  A different node name there means the module renders nothing.

## Known-inert, deliberately left alone

nixos-hardware's `lenovo-legion-16ithg6` sets two things that do nothing on this machine.
Neither is worth overriding - neutralising an upstream no-op is more code for no effect.

- `services.xserver.dpi = 189` - the whole xserver module is `mkIf cfg.enable` and
  `services.xserver.enable` is `false` here (Wayland).
- `common/hidpi.nix`'s console font - gated on kernel < 6.8, and this host runs 6.18.62,
  where the kernel picks a 16x32 console font itself.

## Cost of the battery-saver boot entry

`hardware.nvidia.primeBatterySaverSpecialisation = true` adds a second systemd-boot entry
with the dGPU blacklisted. Measured by comparing derivations: `kernel` and `modulesTree`
are shared with the default config, `etc` and `initialRamdisk` are not. So each generation
roots one extra initrd plus a second `etc`, and `nix-collect-garbage` frees that much less.
Measure after switching with
`nix path-info -Sh /run/current-system /run/current-system/specialisation/battery-saver`.

That entry only boots because the four nvidia-primary variables are absent from this host's
`ENV-Variables.conf`: with `GBM_BACKEND=nvidia-drm` exported, Hyprland cannot start on a
boot where nvidia is blacklisted. Those two decisions belong together.
