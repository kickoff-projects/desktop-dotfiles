{ pkgs, ... }:

{
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      # intel_pstate reads energy_performance_preference. It accepts only
      # these values: performance, balance_performance, default,
      # balance_power, power.
      # Run "tlp-stat -p" to see the value in use.
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";

      WIFI_PWR_ON_AC = "on";
      WIFI_PWR_ON_BAT = "on";
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      CPU_MIN_PERF_ON_AC = 10;
      CPU_MAX_PERF_ON_AC = 90;
      CPU_MIN_PERF_ON_BAT = 10;
      CPU_MAX_PERF_ON_BAT = 50;

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      MEM_SLEEP_ON_AC = "deep";
      MEM_SLEEP_ON_BAT = "deep";

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      INTEL_GPU_MIN_FREQ_ON_AC = 600;
      INTEL_GPU_MIN_FREQ_ON_BAT = 600;
    };
  };

  # upower sends the battery level over DBus and runs the critical action.
  # TLP controls power, but it does not watch the charge level. Waybar reads
  # sysfs directly, and hypridle has no battery logic.
  services.upower.enable = true;

  # The default criticalPowerAction is HybridSleep. HybridSleep needs
  # hibernate, and this host has no hibernate: boot.resumeDevice is empty.
  # PowerOff always works.
  # Change this to "HybridSleep" after you set boot.resumeDevice. First
  # confirm that "systemctl hibernate" resumes correctly.
  services.upower.criticalPowerAction = "PowerOff";

  # These levels are percentages, not time estimates. usePercentageForPolicy
  # is true by default.
  # Only percentageAction acts on its own. It starts criticalPowerAction
  # above.
  # The session reacts to percentageLow and percentageCritical. The
  # battery-alarm service below and the #battery.warning rule in
  # users/nansus/.config/waybar/style.css read these two levels.
  services.upower.percentageLow = 25;
  services.upower.percentageCritical = 10;
  services.upower.percentageAction = 2;

  # Low battery alarm. upower runs percentageAction at 2%. This service warns
  # the user before that level.
  # This configuration has no notification daemon, so notify-send does
  # nothing. A fullscreen window hides the waybar battery module.
  # The compositor shows "hyprctl notify" itself. It shows over fullscreen
  # clients, and it needs no daemon. The sound warns a user who does not
  # watch the screen.
  #
  # This is a systemd user unit, not a system unit, because hyprctl needs its
  # own session. Only hosts/laptop imports this file. The unit therefore
  # reaches every account on this machine and no account on the desktop. The
  # BAT0 test in the script gives extra safety.
  systemd.user.services.battery-alarm = {
    description = "Warn on low battery, on screen and audibly";
    serviceConfig = {
      Type = "oneshot";
      # hyprctl comes from the system closure, not from any user profile.
      Environment = "PATH=/run/current-system/sw/bin";
      ExecStart = pkgs.writeShellScript "battery-alarm" ''
        bat=/sys/class/power_supply/BAT0
        [ -d "$bat" ] || exit 0

        cap=$(cat "$bat/capacity" 2>/dev/null) || exit 0
        [ "$(cat "$bat/status" 2>/dev/null)" = Discharging ] || exit 0

        # hyprctl notify <icon> <ms> <colour> <message>. Icon 3 is the error
        # glyph. Icon 0 is the warning glyph.
        # These levels follow percentageLow and percentageCritical above.
        # Level 5 is the last warning before 2% stops the machine.
        if [ "$cap" -le 5 ]; then
          icon=3; colour="rgb(ff2447)"; beeps=3
          msg="BATTERY $cap% - powering off at 2%"
        elif [ "$cap" -le 10 ]; then
          icon=3; colour="rgb(ff2447)"; beeps=2
          msg="Battery $cap% - plug in now"
        elif [ "$cap" -le 25 ]; then
          icon=0; colour="rgb(ff9500)"; beeps=0
          msg="Battery $cap%"
        else
          exit 0
        fi

        if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && command -v hyprctl >/dev/null 2>&1; then
          hyprctl notify "$icon" 8000 "$colour" "  $msg" >/dev/null 2>&1 || true
        fi

        i=0
        while [ "$i" -lt "$beeps" ]; do
          ${pkgs.pipewire}/bin/pw-play \
            ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/dialog-warning.oga \
            >/dev/null 2>&1 || true
          i=$((i + 1))
        done
      '';
    };
  };

  # The timer runs every 5 minutes, not every minute. At 1 minute, the 25%
  # warning repeats approximately 15 times before the 10% warning starts.
  systemd.user.timers.battery-alarm = {
    description = "Low battery check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      AccuracySec = "10s";
    };
  };

}
