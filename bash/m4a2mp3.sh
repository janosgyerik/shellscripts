#!/bin/sh
#

usage() {
    test "$1" && echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo "Convert M4A files to MP3 using faad and bladeenc"
    exit 1
}

args=
#arg=
#flag=off
#param=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"

#test -f "$1" || usage

try="bladeenc"
converter=
for i in $try; do
    if type $i &> /dev/null ; then converter=$i; break; fi
done

test "$converter" \
    && echo Using converter: $converter \
    || { echo "Couldn't find any of the converters: ${try/ /, }! Exiting." ; exit; }

for i; do
    #rm -f "$i.wav"
    #mkfifo "$i.wav"
    #mplayer -ao pcm "$i" -aofile "$i.wav" &
    faad -o "$i.wav" "$i"
    echo $converter -br 192 \"$i.wav\" \"${i%m4a}mp3\"
    $converter -br 192 "$i.wav" "${i%m4a}mp3"
    rm -f "$i.wav"
done
