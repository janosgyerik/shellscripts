#!/bin/sh
#
# SCRIPT: capitalize.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2005-01-14
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Capitalize the first word or all words in the specified filenames.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... FILE..."
    echo
    echo "Capitalize the first word or all words in filenames."
    echo
    echo "  -g, --global          Capitalize all words, default = $global"
    echo
    echo "  -h, --help            Print this help"
    echo
    exit 1
}

args=
#flag=off
#param=
global=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -g|--global) global=on ;;
    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"

test $# = 0 && usage

test $global = on && g=g || g=

for i in "$@"; do
    file=`basename "$i"`
    dir=`dirname "$i"`
    capitalized=`echo "$file" | tr A-Z a-z | perl -ne "s/((?<=[^\w.'])|^)./\U\$&/$g; print"`
    old="$dir/$file"
    new="$dir/$capitalized"
    test "$new" != "$old" && echo "\`$i' -> \`$new'" && mv -i -- "$i" "$new"
done

# eof
