#!/bin/sh
#
# SCRIPT: icons2square.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2009-11-28
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Pad images with transparency to have equal width and height.
#          Requires ImageMagick ('convert', 'identify')
#
# REV LIST:
#        DATE:  DATE_of_REVISION
#        BY:    AUTHOR_of_MODIFICATION   
#        MODIFICATION: Describe what was modified, new features, etc-
#
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

set -e

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo "Pad images with transparency to have equal width and height"
    echo
    echo "  -w, --width WIDTH    default = $width"
    echo "      --bg BGCOLOR     default = $bg"
    echo "  -o, --outdir OUTDIR  default = $outdir"
    echo
    echo "  -v, --verbose        default = $verbose"
    echo
    echo "  -h, --help           Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
width=
bg=transparent
outdir=
verbose=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -w|--width) shift; width=$1 ;;
    --bg) shift; bg=$1 ;;
    -o|--outdir) shift; outdir=$1 ;;
    -v|--verbose) verbose=on ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

if ! type mogrify 2>/dev/null | grep -o '/.*' >/dev/null; then
    echo The program "'mogrify'" is either not installed or not in \$PATH.
    echo Make sure you have ImageMagick installed. Exit.
    exit 1
fi

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test -f "$1" || usage

test "$outdir" && mkdir -p "$outdir"

msg() {
    echo '* '$*
}

for i; do
    test -f "$i" || continue
    wxh=$(identify "$i" 2>/dev/null | sed -ne 's/.* \([0-9][0-9]*x[0-9][0-9]*\) .*/\1/ p' | head -n 1)
    test "$wxh" || continue
    msg Processing $i ...
    set -- $(echo $wxh | tr x ' ')
    w=$1
    h=$2
    geom=
    if test "$width"; then
        dim=$width
        if test $w -gt $h; then
            if test $w -gt $dim; then
                geom=$dim''x
            fi
        elif test $w -lt $h; then
            if test $h -gt $dim; then
                geom=x$dim
            fi
        else
            if test $w = $dim; then
                test $verbose = on && msg Image is already a square with width/height = $w, skipping ...
                continue
            else
                geom=x$dim
            fi
        fi
    else
        if test $w -gt $h; then
            dim=$w
        elif test $w -lt $h; then
            dim=$h
        else
            test $verbose = on && msg Image is already a square with width/height = $w, skipping ...
            continue
        fi
    fi
    if test "$outdir"; then
        canvas=$outdir/$(basename "$i")-canvas.png
        square=$outdir/$(basename "$i")-square.png
        resized=$outdir/$(basename "$i")-resized.png
        out=$outdir/$(basename "$i")
    else
        canvas="$i"-canvas.png
        square="$i"-square.png
        resized="$i"-resized.png
        out="$i"
    fi
    if test "$geom"; then
        geometry="-geometry $geom"
    else
        geometry=
    fi
    test $verbose = on && msg Creating temporary square image : $square
    composite -gravity center \( "$i" $geometry \) \( -size $dim''x$dim xc:$bg \) "$square"

    test $verbose = on && msg Creating final image : $out
    cp "$square" "$out"
    rm -f "$square"
done
