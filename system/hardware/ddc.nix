{ pkgs, ... }:

{
  # DDC/CI brightness control for the main monitor. The ASUS VG34V on DP-3
  # locks its OSD brightness slider in HDR mode. This machine also has no
  # /sys/class/backlight device, so brightnessctl can control nothing.
  # DDC/CI uses the DisplayPort i2c link instead, at
  # /sys/class/drm/card1-DP-3/ddc. That link does not depend on the OSD lock.
  #
  # hardware.i2c.enable loads the i2c-dev module. That module makes the
  # /dev/i2c-* nodes that ddcutil needs. The option also installs a udev rule
  # with the uaccess tag. That tag gives access to the user who is logged
  # in at the seat. This machine therefore needs no i2c group.
  hardware.i2c.enable = true;

  environment.systemPackages = with pkgs; [
    ddcutil
  ];
}
