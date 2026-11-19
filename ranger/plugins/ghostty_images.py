# Image previews in Ghostty, and character previews inside tmux or herdr.
#
# Ghostty speaks kitty's image protocol, but ranger only uses it when TERM
# contains "kitty". Ghostty is recognised by TERM_PROGRAM instead, because
# ghostty/config.ghostty sets TERM to xterm-256color. Terminal multiplexers
# do not pass the protocol through, so inside one, image previews are turned
# off and scope.sh draws the image with chafa instead.
import os
import tempfile

import ranger.api
import ranger.ext.img_display as img_display
from ranger.ext.img_display import KittyImageDisplayer

MULTIPLEXERS = ("TMUX", "HERDR_ENV", "HERDR_PANE_ID", "ZELLIJ", "STY")


def in_multiplexer():
    return any(os.environ.get(name) for name in MULTIPLEXERS)


_late_init = KittyImageDisplayer._late_init


def _late_init_in_ghostty(self):
    term = os.environ.get("TERM", "")
    if os.environ.get("TERM_PROGRAM") != "ghostty" or in_multiplexer():
        return _late_init(self)
    # Only ranger's name check sees this. Ghostty itself still has to answer
    # the protocol query that follows, so a terminal without support fails as before.
    os.environ["TERM"] = "xterm-kitty"
    try:
        return _late_init(self)
    finally:
        os.environ["TERM"] = term


KittyImageDisplayer._late_init = _late_init_in_ghostty


# The protocol only allows reading a file from /tmp when its name contains
# "tty-graphics-protocol", and Ghostty enforces that. ranger's names do not.
def _protocol_temp_file(*args, prefix="tmp", **kwargs):
    return tempfile.NamedTemporaryFile(*args, prefix="tty-graphics-protocol-" + prefix, **kwargs)


img_display.NamedTemporaryFile = _protocol_temp_file

_hook_init = ranger.api.hook_init


def hook_init(fm):
    if in_multiplexer() and fm.settings.preview_images_method == "kitty":
        fm.settings.preview_images = False
    return _hook_init(fm)


ranger.api.hook_init = hook_init
