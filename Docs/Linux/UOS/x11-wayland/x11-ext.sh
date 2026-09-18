#!/bin/sh

function fix_wayland()
{
    if [ "$XDG_SESSION_TYPE" = "wayland" ];then
        export LD_LIBRARY_PATH="/opt/x11-wayland/lib/aarch64-linux-gnu:${LD_LIBRARY_PATH}"
        if ! cat /proc/cpuinfo | grep -iE "kirin.*9006C|kirin.*990|PANGU.*M900" >/dev/null; then
          export MESA_LOADER_DRIVER_OVERRIDE=zink
        fi
        export LP_NUM_THREADS=2

        export QT_QPA_PLATFORM=xcb
        export XDG_SESSION_TYPE=x11
        unset WAYLAND_DISPLAY
    fi
}

fix_wayland
