#!/bin/sh
#
# SCRIPT: my-external-ip.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2014-03-10
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Find my external IP address
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

set -e

usage() {
    test $# = 0 || echo "$@"
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Find my external IP address
    echo
    echo Options:
    echo
    echo "  -h, --help         Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    --no-flag) flag=off ;;
#    -p|--param) shift; param=$1 ;;
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

#test $# -gt 0 || usage

if which dig >/dev/null; then
    dig +short myip.opendns.com @resolver1.opendns.com
elif which curl >/dev/null; then
    curl ipecho.net/plain
fi
