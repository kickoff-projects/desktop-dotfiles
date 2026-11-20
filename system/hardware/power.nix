{ pkgs, ... }:

{
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      # intel_pstate's energy_performance_preference accepts only
      # performance / balance_performance / default / balance_power / power.
      # This was "balance", which is not in that set. Check what actually
      # landed with "tlp-stat -p".
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

  # TLP manages power, but nothing was watching the charge level: waybar's
  # battery module reads sysfs directly and hypridle has no battery logic,
  # so a critical battery just ended in a hard cut. upower is the daemon
  # that exposes the level over dbus and runs the critical action.
  services.upower.enable = true;

  # upower's default criticalPowerAction is HybridSleep, which needs working
  # hibernate - and hibernate is not set up on this host (boot.resumeDevice
  # is empty even though swapDevices has a partition). A critical battery
  # would therefore hit an action that cannot complete, which is the exact
  # failure upower was enabled to prevent. PowerOff always works; switch
  # this to "HybridSleep" if resumeDevice is ever configured and
  # "systemctl hibernate" is confirmed to come back.
  services.upower.criticalPowerAction = "PowerOff";

  # Percentage based rather than upower's time estimates
  # (usePercentageForPolicy is already true by default). Only percentageAction
  # does anything on its own - it is what fires criticalPowerAction above. Low
  # and critical are the levels the session is expected to react to, which is
  # what the battery-alarm user service in common/home.nix and waybar's
  # #battery.warning rule read.
  services.upower.percentageLow = 25;
  services.upower.percentageCritical = 10;
  services.upower.percentageAction = 2;

  # Low battery alarm. upower runs percentageAction at 2%, but nothing was
  # telling the session before that: there is no notification daemon in this
  # configuration at all, so notify-send would write into the void, and
  # waybar's battery module is invisible under a fullscreen window.
  # "hyprctl notify" is drawn by the compositor itself, so it paints over
  # fullscreen clients without a daemon, and the sound carries when the
  # screen is not being watched.
  #
  # A systemd *user* unit rather than a system one: hyprctl needs the session
  # it belongs to. This file is imported by hosts/laptop only, so it reaches
  # every account on this machine and no account on the Desktop - the BAT0
  # guard in the script is belt and braces for that.
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

        # hyprctl notify <icon> <ms> <colour> <message>: icon 3 is the error
        # glyph, 0 the warning one. Levels follow percentageLow /
        # percentageCritical above, with 5 as the last call before 2% cuts
        # the machine off.
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

  # Every five minutes, not every minute: between 25% and 10% the 25% tier
  # would otherwise repeat fifteen-odd times before the red one starts.
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
