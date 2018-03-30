#!/usr/bin/env bash
#
# SCRIPT: bak.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2004-11-28
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Move or copy files and directories with .bak or .YYYYMMDD suffix
#

set -euo pipefail

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$@"
        exitcode=1
    fi
    echo "Usage: $0 [OPTION]..."
    echo
    echo "Move or copy files and directories with .bak or .YYYYMMDD suffix"
    echo
    echo "  --move, --mv        Move files, default = $move"
    echo "  --copy, --cp        Copy files, default = $copy"
    echo
    echo "  --date, -d          Use .YYYYMMDD suffix, default = $suffix"
    echo "  --timestamp, --ts   Use .YYYYmmddHHMMSS suffix, default = $suffix"
    echo "  --suffix SUFFIX     Use custom suffix, default = $suffix"
    echo
    echo "  -h, --help          Print this help"
    echo
    exit $exitcode
}


args=
move=on
copy=off
suffix=.bak
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    --copy|--cp) copy=on; move=off ;;
    --move|--mv) move=on; copy=off ;;
    --date|-d) suffix=.$(date +%Y%m%d) ;;
    --timestamp|--ts) suffix=.$(date +%Y%m%d%H%M%S) ;;
    --suffix) shift; suffix=$1 ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    esac
    shift
done

eval "set -- $args"

[ $# != 0 ] || usage "Error: specify files to backup"

test $move = off && cmd="cp -vRi --" || cmd="mv -vi --"
for source; do
    fn=${source%%/}
    $cmd "$source" "$fn$suffix"
done
