#!/usr/bin/env bash

STATE_FILE="/tmp/waybar-visible-state"

is_visible() {
  [[ -f "$STATE_FILE" ]] && [[ "$(cat "$STATE_FILE")" == "1" ]]
}

show_bar() {
  if ! is_visible; then
    killall -SIGUSR1 waybar
    echo 1 >"$STATE_FILE"
  fi
}

hide_bar() {
  if is_visible; then
    killall -SIGUSR1 waybar
    echo 0 >"$STATE_FILE"
  fi
}

check() {
  ws=$(hyprctl activeworkspace -j | jq '.id')

  tiled_windows=$(hyprctl clients -j | jq --argjson ws "$ws" '
    [
      .[]
      | select(.workspace.id == $ws)
      | select(.floating == false)
    ] | length
  ')

  if [[ "$tiled_windows" == "1" ]]; then
    hide_bar
  else
    show_bar
  fi
}

echo 1 >"$STATE_FILE"
check

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" |
  while read -r line; do
    case "$line" in
    workspace* | openwindow* | closewindow* | movewindow* | changefloatingmode*)
      check
      ;;
    esac
  done
