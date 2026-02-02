
{...}: {
    # EarlyOOM prevents freezes due to running out of memory.
    # Checks the amount of available memory and free swap up to
    # 10 times a second (less often if there is a lot of free memory).
    # By default if both are below min values, it will
    # kill the largest process (highest oom_score)
    services.earlyoom = {
      enable = true;
      # Minimum of availabe memory (in percent). If the free
      # memory falls below this threshold and the analog is true
      # for freeSwapThreshold the killing begins
      freeMemThreshold = 10;
      # Minimum of availabe swap space (in percent). If the
      # available swap space falls below this threshold and the
      # analog is true for freeMemThreshold the killing begins
      freeSwapThreshold = 10;
      # Send notifications about killed processes via the system d-bus.
      enableNotifications = true;
    };
}
