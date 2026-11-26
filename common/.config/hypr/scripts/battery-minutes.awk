# Waybar custom module: minutes to empty or to full, with no hour column.
# The battery module cannot do this: its format-time splits hours from
# minutes and has no total-minutes argument, so {M} is the 0-59 remainder.
# One read of uevent holds every value, so this needs no shell and no
# second process.
# The values are microwatt-hours and microwatts.
#
# The capacity and the icon stay in the battery module beside this one. This
# script prints the minute count alone.
# Empty output hides a custom module, so every case without an estimate
# prints nothing and the bar then shows the battery module alone.
BEGIN { FS = "=" }

/^POWER_SUPPLY_(STATUS|POWER_NOW|ENERGY_NOW|ENERGY_FULL)=/ { v[$1] = $2 }

END {
  p = v["POWER_SUPPLY_POWER_NOW"]
  s = v["POWER_SUPPLY_STATUS"]

  # power_now is 0 on a full battery and for a few seconds after a plug
  # change. No draw means no estimate.
  if (p + 0 == 0) exit

  if (s == "Discharging") left = v["POWER_SUPPLY_ENERGY_NOW"]
  else if (s == "Charging") left = v["POWER_SUPPLY_ENERGY_FULL"] - v["POWER_SUPPLY_ENERGY_NOW"]
  else exit

  printf "%d min\n", left * 60 / p
}
