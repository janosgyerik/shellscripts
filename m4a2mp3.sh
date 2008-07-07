#!/bin/sh
#
# Convert .wav files to .mp3 with an available converter.
# Tried converters: bladeenc
#

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
