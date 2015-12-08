#!/bin/sh
#
# SCRIPT: rip-dvd.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-02-10
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Rip a DVD movie into a high quality DIVX file.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          
# todo
#	the effect of --volume option is unclear. clarify it (read man mencoder and do some tests)
#	alang and slang are used frequently, add them as main options
#

program=mencoder
lamebr=96

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... FILE [-- $program options...]"
    echo
    echo Rip a DVD movie into a high quality DIVX file
    echo
    echo "  -d, --device          DVD device to rip from, default = $device"
    echo "                          Note: the device name must begin with \"/\""
    echo "  -t, --title           Title number to rip, default = $title"
    echo "  -c, --chapter         Chapter number to rip, default = $chapter"
    echo "      --widescreen      Rip in widescreen mode, default = $widescreen"
    echo "      --vbitrate VBR    vbitrate to use, default = $vbitrate"
    echo "                        The higher = better quality = larger file"
    echo "      --volume VOL      default = $volume"
    echo "      --aid AID         Audio ID to use, default = $aid"
    echo "      --test            Rip only the first chapter, for testing, default = $testonly"
    echo
    echo "  -h, --help            Print this help"
    echo
    echo "Frequently used mencoder options:"
    echo "  -alang hu,en,ja,zh"
    echo "  -slang hu,en,ja"
    echo
    exit 1
}

args=
device=
title=1
chapter=
#minutes=
#size=
widescreen=off
testonly=off
vbitrate=1000
volume=6
out=/tmp/unnamed_dvd_rip.avi
mencoder_ops=
aid=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -d|--device) shift; device=$1 ;;
    -t|--title) shift; title=$1 ;;
    -c|--chapter) shift; chapter=$1 ;;
    --widescreen) widescreen=on ;;
    --test) testonly=on ;;
    --vbitrate) shift; vbitrate=$1 ;;
    --volume) shift; volume=$1 ;;
    --aid) shift; aid=$1 ;;
    --) shift; mencoder_ops="$*"; while [ $# != 0 ]; do shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) out=$1 ;;
    esac
    shift
done

if ! type $program >/dev/null 2>&1; then
    echo You need $program to rip DVDs. Exit.
    exit 1
fi

dir=$(dirname "$out")
workdir=$dir/.rip-dvd-sh.$$
mkdir -p "$workdir"
cd "$workdir"

trap "cd ..; rm -r '$workdir'; exit 1" 1 2 3 15

# this directory will not be cleaned up, to allow debugging later
debugdir=/tmp/rip-dvd.sh/$$
mkdir -p $debugdir

test "$device" && dev_op="-dvd-device \"$device\"" || dev_op=

title_op="dvd://$title"

test $testonly = on && chapter=1

test "$chapter" && chapter_op="-chapter $chapter-$chapter" || chapter_op=

test "$aid" && aid_op="-aid $aid" || aid_op=

configured_ops="$dev_op $title_op $chapter_op $aid_op"

common_ops="$configured_ops $mencoder_ops"

# this entire block will be "tee"-d to a logfile
(
echo "* common options: $common_ops"

# extracting the output of cropdetect
# ...uncommenting... too many times it's just far off the actual correct value.
cat <<"EOF" >/dev/null
sleep=5
stderr=$debugdir/err.0
echo "* running $program in the background with cropdetect ..."
echo "  (sleep for $sleep seconds and kill $program ...)"
cmd="$program $common_ops -nosound -ovc raw -vop cropdetect -o dummy.out 2>$stderr >cropdetect.out &"
echo "* command: $cmd"
eval $cmd
sleep $sleep
kill -TERM $!
crop_op=$(tail cropdetect.out | grep crop=[0-9]* | sed -re 's/.*(crop=[0-9:]*).*/\1/' | head -1)

echo "* crop detected: $crop_op"
EOF

# calculating vbitrate:
#   - this is considered a good rule of thumb to create a roughly 700MB file.
#   - but you really want to go for quality you are satisfied with...
#   - so it's definitely best to run several tests with various vbitrates
#     and find a compromise between file size and quality
#if [ ! "$vbitrate" ]; then
#    if [ "$minutes" -a "$size" ]; then
#	seconds=$((minutes * 60))
#	audiosize=$((lamebr / 8 * seconds))
#	free=$((size - audiosize))
#	vbitrate=$((free * 8 / seconds))
#    else
#	vbitrate=$default_vbitrate
#    fi
#fi
#echo "* using vbitrate=$vbitrate"

# scaling
#test $widescreen = on && scale=704:304 || scale=
#scale=

# vop_op
#test "$scale" && vop_op=scale=$scale,$crop_op || vop_op=$crop_op
#echo "* using vop: $vop_op"

lavcopts=vcodec=mpeg4:vhq:v4mv:vbitrate=$vbitrate:dia=6
echo "* using lavcopts: $lavcopts"

# pass 1: copy audio
stderr=$debugdir/err.1
stdout=$debugdir/out.1
echo "* date: $(date)"
echo "* pass 1: copying audio, this will take a LONG while ..."
cmd="$program $common_ops -oac mp3lame -lameopts br=$lamebr:cbr:vol=$volume -ovc frameno -o frameno.avi >$stdout 2>$stderr"
echo "* command: $cmd"
eval nice -n 19 $cmd

# pass 2: vpass=1
stderr=$debugdir/err.2
stdout=$debugdir/out.2
echo "* date: $(date)"
echo "* pass 2: copying video (vpass=1), this will take a LONG while ..."
cmd="$program $common_ops -oac copy -ovc lavc -lavcopts $lavcopts:vpass=1 -o out.avi >$stdout 2>$stderr"
echo "* command: $cmd"
eval nice -n 19 $cmd

# pass 3: vpass=2
stderr=$debugdir/err.3
stdout=$debugdir/out.3
echo "* date: $(date)"
echo "* pass 3: copying video (vpass=2), this will take a LONG while ..."
cmd="$program $common_ops -oac copy -ovc lavc -lavcopts $lavcopts:vpass=2 -o out.avi >$stdout 2>$stderr"
echo "* command: $cmd"
eval nice -n 19 $cmd
echo "* date: $(date)"
) | tee "out.log"

# cleaning up ...
echo "* cleaning up ..."
cd ..
mv "$workdir/out.avi" "$out"
mv "$workdir/out.log" "$out.log"
rm -fr "$workdir"

echo "* done."
echo "* things to check:"
echo "  * audio quality and language of the output file"
echo "  * there is no black border around the movie"
echo "  * dimensions of the output file"
