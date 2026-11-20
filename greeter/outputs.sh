#!/bin/sh
# Give each screen the scale it has on the desktop, so the login screen and
# its cursor are the size you are used to. labwc has no setting for this; it
# leaves it to wlr-randr. Runs inside labwc, just before the login screen
# (see nocturne/templates/greeter.sh).
#
# Keep the scales the same as hypr/lua/monitors.lua. A screen is matched by
# its name or by part of its description, as `wlr-randr` prints them:
#   eDP-1 "Lenovo Group Limited 0x8AB1 (eDP-1)"
scale_for() {
    case "$1" in
        eDP-1\ *) echo 2 ;;
        *"Odyssey G50F"*) echo 1.07 ;;
        *) echo 1 ;;
    esac
}

# Without wlr-randr the screens stay at 1, and shell.qml sizes itself from
# the screen's height instead.
command -v wlr-randr >/dev/null 2>&1 || exit 0

wlr-randr | while IFS= read -r line; do
    case "$line" in
        "" | " "*) continue ;; # details of the screen above
    esac
    wlr-randr --output "${line%% *}" --scale "$(scale_for "$line")"
done
