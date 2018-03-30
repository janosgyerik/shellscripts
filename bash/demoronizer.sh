#!/bin/sh
#
# SCRIPT: demoronizer.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2012-11-01
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Convert non-ascii characters to ascii (rough) equivalents
#

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$@"
        exitcode=1
    fi
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo "Convert non-ascii characters to ascii (rough) equivalents"
    echo
    echo Options:
    echo
    echo "  -h, --help       Print this help"
    echo
    exit $exitcode
}

args=
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

test $# != 0 || usage "Specify files to demoronize"

for file; do
    test -f "$file" || continue
    sed \
        -e "s/’/'/g" \
        -e "s/‘/'/g" \
        -e 's/“/"/g' \
        -e 's/”/"/g' \
        -e 's/—/\&mdash;/g' \
        -e 's/–/\&ndash;/g' \
        -e 's/…/\&hellip;/g' \
        $file
done
