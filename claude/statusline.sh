#!/usr/bin/env bash
# Claude Code status line: directory  branch  model · effort  session id
# Nocturne (see DESIGN.md): plain text, no blocks or pills. The directory is
# bright because it is where you are; everything else recedes. The clock lives
# in the bar, not here.
#
# Colours are the terminal's own slots (15 bright, 7 muted, 8 faint), which
# ghostty/themes/nocturne sets from the palette. So this follows a palette
# change without being generated, like the bat theme.
# Claude Code pipes session info as JSON on stdin.

input=$(cat)

# Inside Herdr, hand the same JSON to the Agent Usage plugin so the sidebar gets
# Claude's 5h/7d limits. Its output is discarded; this status line is unchanged.
# The glob follows the plugin's checkout directory, which moves on every update.
if [ "${HERDR_ENV:-}" = 1 ]; then
  for usagebar in "$HOME"/.config/herdr/plugins/github-installations/usagebar-*/*/checkout/bin/run-statusline.sh; do :; done
  [ -f "$usagebar" ] && bash "$usagebar" <<<"$input" >/dev/null 2>&1
fi

dir=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
session=$(jq -r '.session_id // empty' <<<"$input")
model=$(jq -r '.model.display_name // .model.id // empty' <<<"$input")
# Absent when the current model has no reasoning effort setting
effort=$(jq -r '.effort.level // empty' <<<"$input")
[ -z "$dir" ] && dir=$PWD

# Show the home directory as ~
short_dir=${dir/#$HOME/\~}

# Branch name, or short commit hash when detached; empty outside a repo
branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
  || git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

bright=$'\e[97m'
muted=$'\e[37m'
faint=$'\e[90m'
reset=$'\e[0m'

out="${bright}${short_dir}"
[ -n "$branch" ] && out+="  ${muted}${branch}"
[ -n "$model" ] && out+="  ${faint}${model}${effort:+ · $effort}"
[ -n "$session" ] && out+="  ${faint}${session}"

printf '%s\n' "${out}${reset}"
