#!/bin/sh
#
# SCRIPT: quote.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2014-07-05
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Enclose each line of input within quotes
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
    echo Enclose each line of input within quotes
    echo
    echo Options:
    echo "  -s, --single             Use single quotes"
    echo "  -d, --double             Use double quotes"
    echo "  -c, --char CHAR          Use CHAR as quoting character, default = $char"
    echo "  -l, --left LEFT          Use LEFT as the left quote, default = $left"
    echo "  -r, --right RIGHT        Use RIGHT as the right quote, default = $right"
    echo "  -j, --join               Join the lines, default = $join"
    echo "  -s, --sep SEP            Use separator character when joining lines, default = $sep"
    echo
    echo "  -h, --help               Print this help"
    echo
    exit 1
}

set_char() {
    char=$1
    left=$char
    right=$char
}

args=
#arg=
#flag=off
#param=
char="'"
left=$char
right=$char
join=off
sep=
linesep='\n'
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
    --single) set_char \' ;;
    -d|--double) set_char \" ;;
    -c|--char) shift; set_char "$1" ;;
    -l|--left) shift; left=$1 ;;
    -r|--right) shift; right=$1 ;;
    -j|--join) join=on; linesep=' ' ;;
    --no-join) join=off; linesep='\n' ;;
    -s|--sep) shift; sep=$1 ;;
#    --) shift; while test $# != 0; do args="$args \"$1\""; shift; done; break ;;
    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

quote() {
    printf "$left$1$right$sep$linesep"
}

quote_args() {
    for i; do
        echo "$i"
    done | quote_lines
}

quote_lines() {
    while read line; do
        quote "$line"
    done
}

if test $# -gt 0; then
    quote_args "$@"
else
    quote_lines
fi
test $join = on && echo
