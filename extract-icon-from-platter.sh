#!/bin/sh
#
# SCRIPT: extract-icon-from-platter.sh
# AUTHOR: Janos Gyerik <info@titan2x.com>
# DATE:   2009-01-18
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Extract an icon image from a platter of icon images.
#	   Default parameters are tuned for http://www.iconarchive.com/.
#	   It is probably a good idea to create wrapper scripts around this
#	   one, with appropriate custom parameters.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... PLATTERFILE OUTFILE"
    echo
    echo Extract an icon image from a platter of icon images.
    echo
    echo "      --mx MARGINX     default = $marginx"
    echo "      --my MARGINY     default = $marginy"
    echo "      --uw UNITWIDTH   default = $unitwidth"
    echo "      --uh UNITHEIGHT  default = $unitheight"
    echo "      --ox OFFSETX     default = $offsetx"
    echo "      --oy OFFSETY     default = $offsety"
    echo "  -x, --x XCHOORD      starts with 1, default = $x"
    echo "  -y, --y YCHOORD      starts with 1, default = $y"
    echo "  -w, --width WIDTH    default = $width"
    echo "      --height HEIGHT  default = $height"
    echo
    echo "  -b, --border         add a red border (to debug), default = $border"
    echo "      --no-border      default = ! $border"
    echo
    echo "  -h, --help           Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
marginx=0
marginy=0
unitwidth=96
unitheight=58
offsetx=3
offsety=8
x=1
y=1
width=48
height=48
border=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    --no-flag) flag=off ;;
#    -p|--param) shift; param=$1 ;;
    --mx) shift; marginx=$1 ;;
    --my) shift; marginy=$1 ;;
    --uw) shift; unitwidth=$1 ;;
    --uh) shift; unitheight=$1 ;;
    --ox) shift; offsetx=$1 ;;
    --oy) shift; offsety=$1 ;;
    -x|--x) shift; x=$1 ;;
    -y|--y) shift; y=$1 ;;
    -w|--width) shift; width=$1 ;;
    --height) shift; height=$1 ;;
    -b|--border) border=on ;;
    --no-border) border=off ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test $# = 2 || usage
test -f "$1" || usage file does not exist: $1

platterfile=$1
outfile=$2

offx=$(expr $marginx + $unitwidth \* \( $x - 1 \) + $offsetx)
offy=$(expr $marginy + $unitheight \* \( $y - 1 \) + $offsety)

convert -crop $width''x$height+$offx+$offy "$platterfile" "$outfile"
test $border = on && convert -border 2x2 -bordercolor '#ff0000' "$outfile" "$outfile"

# eof
