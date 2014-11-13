#!/bin/bash -e
#
# SCRIPT: csv2csv.sh
# AUTHOR: janos <janos@axiom>
# DATE:   2014-03-06
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Convert CSV to CSV using specified locale
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test $# = 0 || echo "$@"
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
    exit 1
}

args=
#arg=
#flag=off
#param=
en=on
fr=off
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
#   -p|--param) shift; param=$1 ;;
    -e|--en) en=on ;;
    -f|--fr) fr=on ;;
#    --) shift; while test $# != 0; do args="$args \"$1\""; shift; done; break ;;
    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
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

if test $# -gt 0; then
    for i; do
        csv2csv < "$i"
    done
else
    csv2csv
fi
