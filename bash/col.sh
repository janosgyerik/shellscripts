#!/usr/bin/env bash
#
# SCRIPT: col.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2012-08-18
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Extract the n-th column of stdin
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

set -euo pipefail

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$@"
        exitcode=1
    fi
    echo "Usage: $0 [OPTION]... COL"
    echo
    echo Extract the n-th column of stdin
    echo
    echo Options:
    echo
    echo "  -h, --help       Print this help"
    echo
    exit $exitcode
}

args=
#arg=
#flag=off
#param=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test $# != 0 || usage "Error: specify columns"

colspec=$(sed -e 's/^/$/' -e 's/ /,$/g' <<< "$*")
awk "{print $colspec}"
