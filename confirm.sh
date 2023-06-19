#!/bin/sh
#
# POSIX-compliant "confirm" prompt, stitched together from snippets on StackOverflow.
#´
MESSAGE=$1
if [ ! "$MESSAGE" = "" ]; then {
    printf "%s\n" "$1 (y/n)";
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty "$old_stty_cfg"
    if [ "$answer" != "${answer#[Yy]}" ];then
        true;
    else
        false;
    fi
}
else {
    echo "confirm called without any message. Aborting."
    exit 1
}
fi