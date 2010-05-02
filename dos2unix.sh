#!/bin/sh
#
# SCRIPT: dos2unix.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2010-05-02
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Remove carriage return from files.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Remove carriage return from files.
    echo
    echo Options:
    echo "  -o, --outdir OUTDIR  default = $outdir"
    echo
    echo "  -h, --help           Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
outdir=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    --no-flag) flag=off ;;
#    -p|--param) shift; param=$1 ;;
    -o|--outdir) shift; outdir=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test -f "$1" || usage

test "$outdir" && mkdir -p "$outdir"

msg() {
    echo '* '$*
}

for i in "$@"; do
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

# eof
