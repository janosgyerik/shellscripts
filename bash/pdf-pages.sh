#!/bin/sh
#
# SCRIPT: pdf-pages.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2008-07-07
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#	    Tested in: hardy/ubuntu
#
# PURPOSE: Cut out a range of pages from PDF files.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... [pdf-file]..."
    echo
    echo Cut out a range of pages from PDF files
    echo
    echo "  -f, --first FIRST  default = $first"
    echo "  -l, --last LAST    default = $last"
    echo
    echo "  -h, --help         Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
first=
last=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -f|--first) shift; first=$1 ;;
    -l|--last) shift; last=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test "$first" -a "$last" || usage

msg() {
    echo "* $*"
}

for path; do
    test -f "$path" || continue
    out=${path%.pdf}-p$first-$last.pdf
    msg "creating $out"
    pdftops -f "$first" -l "$last" "$path" - | ps2pdf - "$out"
    msg "done"
done
