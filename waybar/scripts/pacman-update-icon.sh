#!/usr/bin/env bash

pkgs=$("$HOME/.config/waybar/scripts/checkupdates" 2>/dev/null | wc -l)

if [ "$pkgs" -gt 0 ]; then
    echo "$pkgs"
fi
