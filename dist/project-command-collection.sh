#!/usr/bin/env bash

#
# © 2025 hagre1 <hagre1@pm.me>
# Repository: https://github.com/hagre1/linux-org-helpers
# License: Apache License 2.0 (see LICENSE)
# Version: 20250606-1-1-1S
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


# --------------
# Check terminal


if command -v exo-open &> /dev/null; then
  TERMINAL_LAUNCH="exo-open --launch TerminalEmulator --command"
elif command -v x-terminal-emulator &> /dev/null; then
  TERMINAL_LAUNCH="x-terminal-emulator -e"
elif command -v gnome-terminal &> /dev/null; then
  TERMINAL_LAUNCH="gnome-terminal --"
elif command -v konsole &> /dev/null; then
  TERMINAL_LAUNCH="konsole --separate -e"
elif command -v xfce4-terminal &> /dev/null; then
  TERMINAL_LAUNCH="xfce4-terminal --command"
elif command -v xterm &> /dev/null; then
  TERMINAL_LAUNCH="xterm -e"
else
  echo "===== Error: No terminal launcher was found."
  exit 1
fi


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

# Map of display number to array index (to counter dash entries)
declare -A DISPLAY_TO_INDEX
display=0

for i in "${!OPTIONS[@]}"; do
  if [[ "${OPTIONS[$i]}" == "-" ]]; then
    printf '%*s\n' 32 '' | tr ' ' '-'
  else
    display=$((display + 1))
    DISPLAY_TO_INDEX[$display]=$i
    IFS='#' read -r NAME _ _ <<< "${OPTIONS[$i]}"
    printf "%d: %s\n" "$display" "$NAME"
  fi
done


# ---------
# Execution


# Read user choice
read -e -p $'\n===== [PROMPT] CHOOSE OPTION: ' CHOICE

# Execute user choice
if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [[ -n "${DISPLAY_TO_INDEX[$CHOICE]}" ]]; then
  real_index=${DISPLAY_TO_INDEX[$CHOICE]}
  IFS='#' read -r NAME USE_WINDOW CMD <<< "${OPTIONS[$real_index]}"

  echo -e "\n===== $NAME >>> is being executed ...\n"

  if [[ "$USE_WINDOW" == "true" ]]; then
    echo -e "\n===== $NAME >>> is being executed in a new window without work-dir."
    $TERMINAL_LAUNCH "bash -c '$CMD; exec bash'"
  elif [[ -n "$USE_WINDOW" && "$USE_WINDOW" != "false" ]]; then
    echo -e "\n===== $NAME >>> is being executed in a new window with work-dir '$USE_WINDOW'.\n"
     $TERMINAL_LAUNCH "bash -c 'cd \"$USE_WINDOW\" && $CMD; exec bash'"
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
