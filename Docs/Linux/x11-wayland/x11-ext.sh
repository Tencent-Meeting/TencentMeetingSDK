#!/bin/bash

SELF=$(readlink -f "${BASH_SOURCE[0]}")
XWAYLAND_SHELL_HERE=${SELF%/*}

fix_wayland() {
  export LP_NUM_THREADS=2
  export QT_QPA_PLATFORM=xcb
  export XDG_SESSION_TYPE=x11
  unset WAYLAND_DISPLAY
}

OS_NAME=$(grep "^ID=" /etc/os-release | cut -d= -f2)
if [ "${OS_NAME}" = "uos" ]; then
  LOCAL_MINOR_VERSION=$(grep "^MinorVersion=" /etc/os-version | cut -d= -f2)
  if [ "${LOCAL_MINOR_VERSION}" -lt 1050 ]; then
    MINOR_VERSION=1040
    XWAYLAND_RESULT=0
  elif [ "${LOCAL_MINOR_VERSION}" -lt 1070 ]; then
    MINOR_VERSION=1050
    XWAYLAND_RESULT=0
  else
    XWAYLAND_RESULT=0
  fi
fi

[[ $XWAYLAND_RESULT -eq "0" ]] && fix_wayland

if [[ -n $MINOR_VERSION ]]; then
  export LD_LIBRARY_PATH="${XWAYLAND_SHELL_HERE}/${MINOR_VERSION}/lib/aarch64-linux-gnu:${LD_LIBRARY_PATH}"
fi

export WEMEET_XWAYLAND=${XWAYLAND_RESULT:-1}

