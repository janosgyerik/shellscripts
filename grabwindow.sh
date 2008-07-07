#!/bin/sh
#
# Grab a window and save into file with specified extension.
# Try -h|--help flags for usage info.
#

programname=`basename $0`
usage () {
    echo ""
    echo "usage: $programname [-h|--help] [-r|--root] [-f|--frame] <output>.<ext>"
    echo ""
    echo "This program grabs the root window or a window selected by the mouse and saves "
    echo "it in the file <output>.<ext>. The image format is determined by <ext>. "
    echo "Conversion is done via 'convert' of ImageMagick."
    echo ""
    exit
}

out=/tmp/$programname.xwd
while [ "$#" != 0 ]; do
    case $1 in
    -r|--root) root="-root" ;;
    -f|--frame) frame="-frame" ;;
    -h|--help) usage ;;
    *) args=$1 ;;
    esac
    shift
done

#test -z "$args" && usage

set -x
xwd -out "$out" $frame $root
test "$args" && convert "$out" "$args"
