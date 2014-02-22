#!/bin/sh -e
#
# SCRIPT: bak.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2004-11-28
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Move or copy files and directories with .bak or .YYYYMMDD suffix
#
# REV LIST:
#        DATE:  DATE_of_REVISION
#        BY:    AUTHOR_of_MODIFICATION   
#        MODIFICATION: Describe what was modified, new features, etc-
#
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test $# = 0 || echo "$@"
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
    exit 1
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
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"

test $move = off && cmd="cp -vRi --" || cmd="mv -vi --"
for i; do
    j=${i%%/}
    $cmd "$i" "$j$suffix"
done

# eof
