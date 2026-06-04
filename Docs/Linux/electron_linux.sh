#!/bin/bash

os_release="/etc/os-release"
if [[ -e ${os_release} ]];then
  source /etc/os-release
  main=`echo ${VERSION_ID} | awk -F . '{print $1}'`
  case $ID in
  ubuntu)
    if [[ ${main} -le "16" ]];then
      zenity --info --title="腾讯会议" --text="腾讯会议检测到您操作系统版本过低，请升级系统到ubuntu18.04或以上版本！" --width=350 --height=100
      exit 1
    fi
    
    if [[ ${main} -le "18" ]];then
      if [ $XMODIFIERS ];then
        im_module=$XMODIFIERS
        echo 'use XMODIFIERS'
        export QT_IM_MODULE=${im_module#*=}
      elif [ $GTK_IM_MODULE ];then
        echo 'use GTK_IM_MODULE'
        export QT_IM_MODULE=${GTK_IM_MODULE}
      fi
      echo ${QT_IM_MODULE}
    fi
    ;;
  *)
    ;;
  esac
fi

if [ "$XDG_SESSION_TYPE" = "wayland" ];then
  if [ -f "/opt/x11-wayland/x11-ext.sh" ];then
    source /opt/x11-wayland/x11-ext.sh
  else
    export QT_QPA_PLATFORM=xcb
    export XDG_SESSION_TYPE=x11
    unset WAYLAND_DISPLAY
    export WEMEET_XWAYLAND=1
  fi
fi

SELF=$(readlink -f "$0")
HERE=${SELF%/*}

export LC_ALL=zh_CN.UTF-8
export PATH="${HERE}:${HERE}/Release${PATH:+:$PATH}"
export LD_LIBRARY_PATH="${HERE}/Release/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="${HERE}/Release/plugins"
export TZ=Asia/Shanghai