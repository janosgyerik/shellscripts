#!/bin/sh
#
# SCRIPT: iconv-filenames.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-11-07
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Convert the encoding of filenames (if possible).
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

program=iconv

if ! type $program >/dev/null 2>/dev/null; then
    echo "You need $program to convert the encoding of filenames. Exit."
    exit 1
fi

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo "Convert the encoding of filenames (if possible)"
    echo
    echo "  -f, --from ENCODING  "
    echo "  -t, --to ENCODING    "
    echo
    echo "  -l, --list           list all known coded character sets"
    echo
    echo "  -h, --help           Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
from=
to=
list=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -f|--from) shift; from=$1 ;;
    -t|--to) shift; to=$1 ;;
    -l|--list) list=on ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

test $list = on && { $program -l ; exit 0 ; }

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test $# -gt 0 || usage

test "$from" && from_op="-f $from" || from_op=
test "$to" && to_op="-f $to" || to_op=

for i in "$@"; do
    newname="$(echo $i | $program $from_op $to_op 2>/dev/null)"
    if test $? = 1; then
	echo "\`$i' -> ? (cannot convert)"
    elif test "$i" != "$newname"; then
	echo "\`$i' -> \`$newname'"
	mv -i "$i" "$newname"
    fi
done
