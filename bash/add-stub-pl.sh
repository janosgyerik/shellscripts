#!/bin/sh
#
# SCRIPT: add-stub-pl.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-01-27
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Insert a stub template after the first line of a perl script.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test "$1" && echo $@
    echo "Usage: $0 [OPTION]... [FILE]..."
    echo
    echo "Insert a script header after the first line of a perl script."
    exit 1
}

args=
#flag=off
#param=
test "$AUTHOR" && author=$AUTHOR || author='AUTHOR <email@address.com>'
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -a|--author) shift; author=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"

test -f "$1" || usage

for i in "$@"; do
    test -f "$i" || continue
    echo Adding stub to $i ...
    tmp="$i".tmp
    > "$tmp"
    head -n 1 "$i" >> "$tmp"
    cat << EOF >> "$tmp"
#
# SCRIPT: $(basename "$i")
# AUTHOR: $author
# DATE:   $(date +%F)
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
# PLATFORM: Linux only
# PLATFORM: FreeBSD only
#
# PURPOSE: Give a clear, and if necessary, long, description of the
#          purpose of the shell script. This will also help you stay
#          focused on the task at hand.
#
EOF
    tail -n +2 "$i" >> "$tmp"
    cp "$tmp" "$i"
    rm -f "$tmp"
done
