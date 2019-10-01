#!/bin/sh

if (locale | grep -e 'utf8' -e 'UTF-8') >/dev/null 2>&1; then logo="📖  "; else logo=""; fi
ROOT_DIR=$( cd "$(dirname "$0")" ; pwd -P )

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
   echo $SHORTCUT_DISPLAY
}