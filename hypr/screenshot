#!/bin/bash
grim -g "$(slurp)" - | wl-copy && wl-paste > ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png | notify-send -i image -a wl-copy -u normal "Screenshot of the region taken" -t 1000 # screenshot of a region 
