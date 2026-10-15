#!/bin/bash

SELF=$(readlink -f "${BASH_SOURCE[0]}")
XWAYLAND_SHELL_HERE=${SELF%/*}

function fix_wayland()
{
    if [ "$XDG_SESSION_TYPE" = "wayland" ];then
        export LD_LIBRARY_PATH="${XWAYLAND_SHELL_HERE}/lib/aarch64-linux-gnu:${LD_LIBRARY_PATH}"
        if ! cat /proc/cpuinfo | grep -iE "kirin.*9006C|kirin.*990|PANGU.*M900" >/dev/null; then
          export MESA_LOADER_DRIVER_OVERRIDE=zink
        fi
        export LP_NUM_THREADS=2

        export QT_QPA_PLATFORM=xcb
        export XDG_SESSION_TYPE=x11
        unset WAYLAND_DISPLAY
    fi
}

OS_NAME=$(grep "^ID=" /etc/os-release | cut -d= -f2)
if [ "${OS_NAME}" = "uos" ]; then
  XWAYLAND_RESULT=0
fi

[[ $XWAYLAND_RESULT -eq "0" ]] && fix_wayland

export WEMEET_XWAYLAND=${XWAYLAND_RESULT:-1}

