#!/bin/sh
#
# SCRIPT: slugify.sh
# AUTHOR: janos <janos@frostgiant>
# DATE:   2018-01-09
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
# PLATFORM: Linux only
# PLATFORM: FreeBSD only
#
# PURPOSE: BRIEF DESCRIPTION OF THE SCRIPT
#          Give a clear, and if necessary, long, description of the
#          purpose of the shell script. This will also help you stay
#          focused on the task at hand.
#

set -e

usage() {
    test $# = 0 || echo "$@"
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo BRIEF DESCRIPTION OF THE SCRIPT
    echo
    echo Options:
    echo
    echo "  -h, --help         Print this help"
    echo
    exit 1
}

args=
#flag=off
#param=
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    --no-flag) flag=off ;;
#    -p|--param) shift; param=$1 ;;
#    --) shift; while test $# != 0; do args="$args \"$1\""; shift; done; break ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

slugify() {
    sed -e 's/./\L&/g' -e 's/[^a-z0-9_][^a-z0-9]*/-/g'
}

if test $# != 0; then
    echo "$*" | slugify
else
    slugify
fi
