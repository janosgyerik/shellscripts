#!/usr/bin/env bash
#
# SCRIPT: csv2csv.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2014-03-06
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Convert CSV to CSV using specified locale
#

set -euo pipefail

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$@"
        exitcode=1
    fi
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Convert CSV to CSV using specified locale
    echo
    echo Options:
    echo "      --en           default = $en"
    echo "      --fr           default = $fr"
    echo
    echo "  -h, --help         Print this help"
    echo
    exit $exitcode
}

args=
en=on
fr=off
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
    -e|--en) en=on ;;
    -f|--fr) fr=on ;;
    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

csv2csv() {
    if test $fr = on; then
        tr ., ',;'
    else
        tr ',;' .,
    fi
}

if test $# != 0; then
    for path; do
        csv2csv < "$path"
    done
else
    csv2csv
fi
