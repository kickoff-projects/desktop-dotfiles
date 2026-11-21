{ pkgs, ... }:

{
  # DDC/CI brightness control for the main monitor. The ASUS VG34V on DP-3
  # locks its OSD brightness slider while it is in HDR mode, and the box has no
  # /sys/class/backlight device, so brightnessctl has nothing to drive. DDC/CI
  # talks to the monitor over the DisplayPort i2c link instead
  # (/sys/class/drm/card1-DP-3/ddc), which is independent of the OSD lock.
  #
  # hardware.i2c.enable loads the i2c-dev module, which is what creates the
  # /dev/i2c-* nodes ddcutil needs, and installs a udev rule tagged uaccess.
  # That tag grants the seat's logged-in user access, so no i2c group
  # membership is required.
  hardware.i2c.enable = true;

  environment.systemPackages = with pkgs; [
    ddcutil
  ];
}
