#!/bin/sh
#
# SCRIPT: dos2unix.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2010-05-02
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Remove carriage return from files.
#

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$@"
        exitcode=1
    fi
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Remove carriage return from files
    echo
    echo Options:
    echo "  -o, --outdir OUTDIR  default = $outdir"
    echo
    echo "  -h, --help           Print this help"
    echo
    exit 1
}

args=
outdir=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -o|--outdir) shift; outdir=$1 ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test $# != 0 || usage "Specify files to convert"

test "$outdir" && mkdir -p "$outdir"

msg() {
    echo '* '$*
}

for i; do
    test -f "$i" || continue
    if test "$outdir"; then
        msg creating $outdir/$(basename "$i") ...
        cp "$i" "$outdir"
        tr -d '\r' < "$i" > "$outdir"/"$(basename "$i")"
    else
        msg converting $i ...
        tr -d '\r' < "$i" > "$i".unix
        cat "$i".unix > "$i" # this way permissions are preserved
        rm "$i".unix
    fi
done
