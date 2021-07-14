#!/usr/bin/env bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-$0}" )" &> /dev/null && pwd )"

source $ROOT_DIR/src/helpers/common.sh

SHORTCUT_DISPLAY="${logo} Available Shortcuts:\n"

shortcuts=($ROOT_DIR/src/*.sh)
for shortcut in "${shortcuts[@]}"; do
   SHORTCUT_DISPLAY="$SHORTCUT_DISPLAY\t$(basename $shortcut .sh):\n"

   shortnames=(
      $(cat $shortcut | grep '^function' | awk -v FS="(function|{)" '{print $2}')
      $(cat $shortcut | grep '^alias' | awk -v FS="(alias|=)" '{print $2}')
   )

   for shortname in ${shortnames[@]}; do
      SHORTCUT_DISPLAY="$SHORTCUT_DISPLAY\t\t- $shortname\n"
   done

   source "$shortcut"
done


function morrish {
   printf "$SHORTCUT_DISPLAY"
}