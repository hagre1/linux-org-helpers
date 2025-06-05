#!/usr/bin/env bash

#
# © 2025 hagre1 <hagre1@pm.me>
# Repository: https://github.com/hagre1/linux-org-helpers
# License: Apache License 2.0 (see LICENSE)
# Version: 250605+1L-0-0 (reverse-date+classical-versioning with S/M/L indicating the last change and its impact)
#


# -------
# Helpers


# Function to keep the terminal open when an error occurs
function on_error {
  local exit_code=$?  # Saves the exit code of the latest command
  echo -e "\n===== An error occurred. Script stopped. Press any key to exit."
  echo -e "\n\nFailed command: $BASH_COMMAND"
  echo -e "\n\nExit code: $exit_code"
  read -n 1 -s -r
  exit 1
}

# Function is set to be called on every error
set -o errexit
trap 'on_error' ERR


# ------------------
# Handle config file


# Check for config path and if file exists
if [[ -z "$1" ]] || [[ ! -f "$1" ]]; then
  echo "===== Error : No config file was given (as first parameter) or path was invalid."
  exit 1
fi

# Check for syntax errors
bash -n "$1" 2>/dev/null || {
  echo "===== Error: Syntax error in config file '$1'."
  exit 1
}

# use config_file for more clarity, get local dir
CONFIG_FILE="$1"
DIR="$( dirname "$CONFIG_FILE" )"

# Get the options from config file, user can use DIR in config file
source "$CONFIG_FILE"

# Check if options are available
if [[ -z "${OPTIONS[*]}" ]]; then
  echo "Error: In '$CONFIG_FILE' no array \$OPTIONS was found. Or it is empty."
  exit 1
fi


# -----------
# Output menu


echo -e "===== OPTIONS (project dir: $DIR):\n"
for i in "${!OPTIONS[@]}"; do
  IFS='#' read -r NAME _ _ <<< "${OPTIONS[$i]}"
  printf "%d: %s\n" $((i + 1)) "$NAME"
done

# Read user choice
read -e -p $'\n===== [PROMPT] CHOOSE OPTION: ' CHOICE


# --------------
# Check terminal


if command -v exo-open &> /dev/null; then
  TERMINAL_LAUNCH="exo-open --launch TerminalEmulator"
elif command -v x-terminal-emulator &> /dev/null; then
  TERMINAL_LAUNCH="x-terminal-emulator"
elif command -v gnome-terminal &> /dev/null; then
  TERMINAL_LAUNCH="gnome-terminal"
elif command -v konsole &> /dev/null; then
  TERMINAL_LAUNCH="konsole"
elif command -v xfce4-terminal &> /dev/null; then
  TERMINAL_LAUNCH="xfce4-terminal"
elif command -v xterm &> /dev/null; then
  TERMINAL_LAUNCH="xterm -e"
else
  echo "===== Error: No terminal launcher was found."
  exit 1
fi


# ---------
# Execution


if [[ "$CHOICE" =~ ^[0-9]+$ ]] && (( CHOICE >= 1 && CHOICE <= ${#OPTIONS[@]} )); then
  INDEX=$((CHOICE - 1))
  IFS='#' read -r NAME USE_WINDOW CMD <<< "${OPTIONS[$INDEX]}"

  echo -e "\n===== $NAME >>> is being executed ...\n"

  if [[ "$USE_WINDOW" == "true" ]]; then
    $TERMINAL_LAUNCH "bash -c '$CMD; exec bash'"
    echo -e "\n===== $NAME >>> is being executed in a new window without work-dir."
  elif [[ -n "$USE_WINDOW" && "$USE_WINDOW" != "false" ]]; then
    $TERMINAL_LAUNCH "bash -c 'cd \"$USE_WINDOW\" && $CMD; exec bash'"
    echo -e "\n===== $NAME >>> is being executed in a new window with work-dir '$USE_WINDOW'."
  else
    bash -c "$CMD"
  fi

else
  echo "Invalid choice!"
  exit 1
fi


# --------------
# Close terminal


echo -e "\n===== Press a key to keep window open or wait 5 sec for automatic closing.\n"
KEY_PRESSED=false

for i in {5..0}; do
  read -t 1 -n 1 key && KEY_PRESSED=true && break
  echo -ne "\rClosing in $i seconds ... "
done

if $KEY_PRESSED; then
  echo -e "\n===== Process completed. Press key to close."
  read -n 1 -s -r
fi

exit 0
