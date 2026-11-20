#!/bin/sh
# What a successful login starts. Both the login screen (shell.qml) and its
# text fallback run this, as `sh /etc/greetd/nocturne/session.sh`.
#
# Hyprland's launcher prints progress lines. They would go to the console,
# which shows for a moment before Hyprland draws, so they are dropped here.
#
# Dropped, not saved: every app Hyprland starts inherits this output, so
# saving it (in a file or the journal) would record what every app prints.
# Hyprland keeps its own log in $XDG_RUNTIME_DIR/hypr/ and writes crash
# reports to ~/.cache/hyprland/.
exec start-hyprland >/dev/null 2>&1
