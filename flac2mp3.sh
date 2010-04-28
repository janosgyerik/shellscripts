#!/bin/sh
#
# Convert .flac files to .mp3 with flac and lame.
#

require="flac lame"
failed=no
for program in $require; do
    if ! type $program 2>/dev/null >/dev/null; then 
	echo "Error: the program '$program' is not installed or not in PATH"
	failed=yes
    fi
done
test $failed = no || exit 1

for i in "$@"; do
    echo "flac -c -d \"$i\" | lame -m j -b 192 -s 44.1 - \"${i%.flac}.mp3\""
    flac -c -d "$i" | lame -m j -b 192 -s 44.1 - "${i%.flac}.mp3"
done

# end of script
