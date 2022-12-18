#!/bin/bash

# Check if there is any tmux session running
if tmux ls 2>/dev/null | grep -q .; then
    # Attach to the first running tmux session
    tmux attach-session -t $(tmux ls | head -n 1 | cut -d: -f1)
else
    # Start a new tmux session
    tmux
fi
