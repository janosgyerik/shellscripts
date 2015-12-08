#!/bin/sh
#
# SCRIPT: icons2dim.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2008-11-08
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Resize icon images to have specified width and height.
#		* extra pixels are sliced off evenly from all edges
#		* pad with transparent pixels evenly to all edges
#		* resized icons are saved in specified target directory
#		* requires ImageMagick ('convert')
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
    echo Resize icon images to have specified width and height
    echo
    echo "  -w, --width WIDTH    default = $width"
    echo "  -H, --height HEIGHT  default = $height"
    echo "      --bg BGCOLOR     default = $bg"
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
width=16
height=16
bg=transparent
outdir=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -w|--width) shift; width=$1 ;;
    -H|--height) shift; height=$1 ;;
    --bg) shift; bg=$1 ;;
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

test $# -gt 0 || usage

# params: cmd
require_cmd() {
    if ! type "$1" | grep -o /.\* >/dev/null; then
	echo "Required command '$1' is missing, install it first. Exit." >&2
	exit 1
    fi
}
require_cmd convert
require_cmd expr

workdir=/tmp/.$$-icons2dim.sh
trap 'rm -fr $workdir; exit 1' 1 2 3 15

mkdir $workdir

test "$outdir" && mkdir -p "$outdir"

convert -size $width''x$height xc:$bg $workdir/canvas.png

for i in "$@"; do
    test -f "$i" || continue
    identify "$i" >/dev/null 2>/dev/null || continue
    echo overlaying canvas for $i ...
    test "$outdir" && o=$outdir || o=$(dirname "$i")
    convert -composite $workdir/canvas.png "$i" -gravity center "$o"/$(basename "$i")
done

rm -fr $workdir
exit
