{ lib, ... }:

# nvidia power management for the laptop only.
# The lenovo-legion-16ithg6 module of nixos-hardware sets the driver, the
# open kernel modules and the Ampere profile. It also sets PRIME offload
# with the bus ids of this machine.
# flake.nix imports that module. It leaves every power option off, which is
# the default of the nvidia module. The four options below are the ones that
# an Ampere laptop needs in offload mode.
#
# The desktop does not import this file. The desktop has no battery, and
# finegrained asserts that prime.offload is enabled. The desktop does not
# use prime.offload.
{
  hardware.nvidia = {
    # RTD3. The dGPU goes down to D3cold when no client holds it. That is the
    # state for most of the time on this machine: the panel runs on the iGPU,
    # and only "nvidia-offload <app>" moves work to the dGPU.
    # This option sets NVreg_DynamicPowerManagement=0x02. It also adds the
    # udev rules that set power/control to auto. It needs
    # prime.offload.enable, which is true here. It needs a Turing GPU or a
    # later GPU. This machine has Ampere.
    #
    # Every program that uses the device stops RTD3 while the program runs.
    # A plain "nvidia-smi" does this too. See the test on the custom/nvidia
    # module in hosts/laptop/.config/waybar/config.jsonc.
    powerManagement.finegrained = true;

    # This option keeps the VRAM contents through suspend and resume. It sets
    # NVreg_PreserveVideoMemoryAllocations=1. Without it, the driver discards
    # the contents. A discard gives a black screen or a lost GL context after
    # a lid-close suspend.
    # The cost is time: suspend must write the VRAM out first.
    # Driver 595 with the open modules also sets kernelSuspendNotifier by
    # default. That option gives suspend and resume to the kernel, and not to
    # the systemd units.
    powerManagement.enable = true;

    # This option lets nvidia-powerd move the shared power budget between the
    # CPU and the dGPU under load. It needs driver 510.39.01 or later. This
    # machine has driver 595. It also needs firmware support from the laptop.
    # nvidia-powerd does not start on hardware without that support.
    # Run "systemctl status nvidia-powerd" after the first rebuild.
    dynamicBoost.enable = true;

    # This option adds a second systemd-boot entry with the name
    # "battery-saver". That entry blacklists nouveau and nvidia, and it
    # removes the PCI functions of the dGPU. The default entry does not
    # change, so this option costs nothing until you boot the new entry. Use
    # the entry on a day that needs no dGPU.
    # The normal boot already holds the dGPU in RTD3 through finegrained
    # above, so the difference under light load is small. The purpose of this
    # entry is that no program can wake the dGPU.
    primeBatterySaverSpecialisation = true;
  };

  # The battery-saver entry of prime.nix forces offload, powerManagement and
  # finegrained off. It does not force dynamicBoost off. That entry therefore
  # keeps the nvidia-powerd unit on a boot that blacklists nvidia, and the
  # unit fails.
  # This line uses the same attribute name as prime.nix. This module
  # therefore adds to the same specialisation and makes no second one.
  specialisation.battery-saver.configuration.hardware.nvidia.dynamicBoost.enable =
    lib.mkForce false;
}
