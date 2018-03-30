#!/usr/bin/env bash
#
# SCRIPT: capitalize.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-01-14
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Capitalize words in the filenames.
#

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$@"
        exitcode=1
    fi
    echo "Usage: $0 [OPTION]... FILE..."
    echo
    echo Capitalize words in filenames
    echo
    echo "  -g, --global          Capitalize all words, default = $global"
    echo
    echo "  -h, --help            Print this help"
    echo
    exit $exitcode
}

args=
global=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -g|--global) global=on ;;
    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    esac
    shift
done

eval "set -- $args"

test $# != 0 || usage "Error: specify file names to capitalize"

test $global = on && g=g || g=

for path; do
    filename=$(basename "$path")
    basedir=$(dirname "$path")
    capitalized=$(perl -pe "tr/A-Z/a-z/; s/((?<=[^\w.'])|^)./\U\$&/$g" <<< "$filename")
    old="$basedir/$filename"
    new="$basedir/$capitalized"

    if test "$new" != "$old"; then
        mv -vi -- "$path" "$new"
    fi
done
