{ lib, ... }:

# Laptop-only nvidia power management. nixos-hardware's
# lenovo-legion-16ithg6 (wired up in flake.nix) sets the driver, the open
# kernel modules, the Ampere profile and PRIME offload with this machine's
# bus ids, but it deliberately leaves every power knob at the nvidia
# module's default of off. These four are the ones an Ampere laptop in
# offload mode wants. Not imported by the Desktop: it has no battery, and
# finegrained asserts on prime.offload being enabled, which the Desktop
# does not use.
{
  hardware.nvidia = {
    # RTD3: lets the dGPU power down to D3cold whenever no client holds it,
    # which on this machine is most of the time - the panel is on the iGPU
    # and only `nvidia-offload <app>` moves work to the dGPU. Sets
    # NVreg_DynamicPowerManagement=0x02 plus the udev rules that put
    # power/control on auto. Requires prime.offload.enable (true here) and
    # Turing or newer (Ampere here).
    #
    # Anything that talks to the device cancels this for as long as it runs,
    # including a plain `nvidia-smi` - see the gate on waybar's
    # custom/nvidia module in hosts/laptop/.config/waybar/config.jsonc.
    powerManagement.finegrained = true;

    # Preserves VRAM contents across suspend/resume
    # (NVreg_PreserveVideoMemoryAllocations=1) instead of letting the driver
    # discard them, which is the usual cause of a black screen or lost GL
    # contexts after a lid-close suspend. The cost is that suspend has to
    # write VRAM out first, so it takes slightly longer. Driver 595 with the
    # open modules also turns on kernelSuspendNotifier by default on top of
    # this, which hands suspend/resume to the kernel rather than to the
    # systemd units.
    powerManagement.enable = true;

    # Lets nvidia-powerd shift the shared power budget between CPU and dGPU
    # under load. Needs driver >= 510.39.01 (595 here) and firmware support
    # from the laptop itself: where the hardware does not support it,
    # nvidia-powerd simply fails to start, so check
    # "systemctl status nvidia-powerd" after the first rebuild.
    dynamicBoost.enable = true;

    # Adds a second systemd-boot entry ("battery-saver") that blacklists
    # nouveau and nvidia and removes the dGPU's PCI functions outright. The
    # default entry is untouched, so this costs nothing until booted - it is
    # there for the days the dGPU is not wanted at all. With finegrained
    # above working, the normal boot already parks the dGPU in RTD3, so the
    # difference on light load is small; the specialisation's point is that
    # nothing can wake it.
    primeBatterySaverSpecialisation = true;
  };

  # prime.nix's battery-saver entry forces offload, powerManagement and
  # finegrained off, but not dynamicBoost - so that entry would still ship
  # the nvidia-powerd unit on a boot where nvidia is blacklisted, and the
  # unit just fails. Same attribute name as prime.nix uses, so this module
  # merges into its specialisation rather than defining a second one.
  specialisation.battery-saver.configuration.hardware.nvidia.dynamicBoost.enable =
    lib.mkForce false;
}
