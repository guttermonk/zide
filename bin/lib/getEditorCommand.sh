#!/usr/bin/env bash
#
# Usage:
#   getEditorCommand "<editor> <command>
#
#   Where <editor> is the name of your text editor (defaults to $EDITOR) and
#   <command> is the command to perform (open, hsplit, vsplit).

# Nothing writes tmp/env any more -- the writer went away with
# ZIDE_EDITOR_CMD_MODE/ZIDE_EDITOR_CD_CMD and only this read was left behind.
# Sourcing it unconditionally puts a "No such file or directory" on stderr on
# every single open, and ZIDE_DIR is read-only in some installs (nix, /usr/local),
# so the file cannot simply be created either.
[ -f "${ZIDE_DIR}/tmp/env" ] && source "${ZIDE_DIR}/tmp/env"

# Mapping of common editors and their commands
declare -A commands=(
  ["hx_cd"]="cd"
  ["hx_open"]="open"
  ["hx_hsplit"]="hsplit"
  ["hx_vsplit"]="vsplit"

  ["helix_cd"]="cd"
  ["helix_open"]="open"
  ["helix_hsplit"]="hsplit"
  ["helix_vsplit"]="vsplit"

  ["kak_cd"]="cd"
  ["kak_open"]="edit"
  ["kak_hsplit"]="edit"
  ["kak_vsplit"]="edit"

  ["nvim_cd"]="cd"
  ["nvim_open"]="edit"
  ["nvim_hsplit"]="split"
  ["nvim_vsplit"]="vsplit"

  ["vim_cd"]="cd"
  ["vim_open"]="edit"
  ["vim_hsplit"]="split"
  ["vim_vsplit"]="vsplit"
)
  
getEditorCommand() {
  local editor="${1:-$EDITOR}"
  local command="${2:-open}"

  # Create a key to look up in the dictionary
  local key="${editor}_${command}"

  # Fetch the corresponding command or show an error
  if [[ -n "${commands[$key]}" ]]; then
    echo "${commands[$key]}"
  else
    echo "${command}"
  fi
}
