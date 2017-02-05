#!/bin/sh
#
# SCRIPT: words.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2014-03-30
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Find words in specified files or directories
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
    echo Find words in specified files or directories
    echo
    echo Options:
    echo "      --minlength              default = $minlength"
    echo "      --maxlength              default = $maxlength"
    echo
    echo "  -h, --help                   Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
minlength=2
maxlength=
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    --no-flag) flag=off ;;
#    -p|--param) shift; param=$1 ;;
    --minlength) shift; minlength=$1 ;;
    --maxlength) shift; maxlength=$1 ;;
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

test $# -gt 0 || usage

words() {
    pattern="\b\w{$minlength,$maxlength}\b"
    grep -Por $pattern $@ | cut -f2- -d:
}

words $@
