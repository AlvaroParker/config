#!/bin/sh
# What a successful login starts. The login screen (shell.qml) runs this as
# `sh /etc/greetd/nocturne/session.sh NAME`, with the session picked in its
# corner; the text fallback runs it with no name, which is Hyprland.
#
#   hyprland  the desktop in this repo
#   gnome     GNOME on Wayland
#   i3        i3 on Xorg, for testing X11 work. startx puts Xorg on this
#             login's console, which is what lets it run without root.
#
# The login screen also hands greetd the session's type (wayland or x11) and
# desktop name, so logind registers the session the way GDM would.
#
# What the sessions print is dropped, not saved: every app they start
# inherits this output, so saving it (in a file or the journal) would record
# what every app prints. Hyprland keeps its own log in $XDG_RUNTIME_DIR/hypr/
# and crash reports in ~/.cache/hyprland/, GNOME logs to the journal, and
# Xorg writes ~/.local/share/xorg/Xorg.0.log.
case "${1:-hyprland}" in
    gnome) exec gnome-session >/dev/null 2>&1 ;;
    i3)
        # startx finds the console from its input. If that is not the
        # console, name it: logind gives its number as XDG_VTNR.
        if ! tty -s && [ -n "${XDG_VTNR:-}" ]; then
            exec startx /usr/bin/i3 -- "vt$XDG_VTNR" -keeptty >/dev/null 2>&1
        fi
        exec startx /usr/bin/i3 >/dev/null 2>&1
        ;;
    *) exec start-hyprland >/dev/null 2>&1 ;;
esac
