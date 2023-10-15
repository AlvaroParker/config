#!/bin/bash

killall polybar
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload main-bar &
    echo "Polybar launched..."
  done
else
  polybar --reload main-bar &
fi

