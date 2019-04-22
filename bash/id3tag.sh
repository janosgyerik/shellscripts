#!/usr/bin/env bash
#
# SCRIPT: id3tag.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2007-05-04
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Linux
#
# PURPOSE: Set id3 v2 tag on mp3 files in the current directory and rename nicely.
#	   The mp3 file names should start with a number, padded by zeros on 
#	   the left to equal length.
#
#	   The script works with mp3 files in the current directory.
#	   The first run creates a $config file with autodetected id3 tag
#	   information and capitalized song titles.
#	   Before running the script again you should edit the $config file
#	   to adjust common id3 tag information such as artist and album,
#	   and song titles as appropriate.
#	   Run the script again to apply the id3 tag info according to $config.
#	   The script also tries to rename files in the format:
#		NN - title.mp3
#	   
#          If the $mp3info program exists, the script will detect the bitrate
#	   and report if it is less than 192 kbps.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

require() {
    local program all_ok=1
    for program; do
        if ! type "$program" &>/dev/null; then
            echo "Error: the required program '$program' is not installed or not in PATH"
            all_ok=
        fi
    done
    test "$all_ok" || exit 1
}

program=id3v2
require "$program"

configfile=./.id3tag.sh
missing=missing
mp3info=mp3info
mp3info_ops=-x
id3v2_list_cmd='id3v2 -l'
id3v2_list_tmpfile=/tmp/.id3tag.sh-$$
trap 'rm -f $id3v2_list_tmpfile' 1 2 3 15

usage() {
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Set id3 v2 tag on mp3 files in the current directory and rename nicely
    echo
    echo The first run creates a configuration in the file $configfile.
    echo Edit $configfile and run the script again to apply the id3 values.
    exit 1
}

args=
while [ "$#" != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    --) shift; args="$args $@"; shift "$#" ;;
    -?*) echo Unknown option: $1; usage ;;
    *) args="$args $1" ;;
    esac
    shift
done

update_tags() {
    pattern=$1
    test "$2" && no_tid=on || no_tid=off
    cat $configfile | grep $pattern | while read line; do
	tid=$(echo $line | cut -f1 -d= | cut -f2 -d_)
	title=$(eval echo \$t_$tid)
	test "$title" || title="Track $tid"
	if test $no_tid = off; then
	    filename="$tid - $title.mp3"
	else
	    filename="$title.mp3"
	fi
	if test ! -f "$filename"; then
	    match=$(ls $tid* 2>/dev/null | head -n 1)
	    if test -f "$match"; then
		echo mv "$match" "$filename"
		mv "$match" "$filename"
	    fi
	fi
	test $no_tid = on && tid=99
	if test -f "$filename"; then
	    extra=
	    if test "$mp3info"; then
		if ! $mp3info $mp3info_ops "$filename" | grep "192 kbps" >/dev/null 2>/dev/null; then
		    extra="( not 192 kbps, >> $missing )"
		    echo $filename "*** not 192 kbps ***" >> $missing
		fi
	    fi
	    echo Tagging \"$filename\" ... $extra
	    if test "$artist"; then
		echo $program --artist "$artist" --song "$title" --album "$album" --genre "$genre" --year "$year" --track $tid/$tracks "$filename"
		$program --artist "$artist" --song "$title" --album "$album" --genre "$genre" --year "$year" --track $tid/$tracks "$filename" > /dev/null
	    else
		echo $program --song "$title" --album "$album" --genre "$genre" --year "$year" --track $tid/$tracks "$filename"
		$program --song "$title" --album "$album" --genre "$genre" --year "$year" --track $tid/$tracks "$filename" > /dev/null
	    fi
	else
	    echo Missing \"$filename\" ... "( >> $missing )"
	    echo $filename >> $missing
	fi
    done
}

if test -f $configfile; then
    if test "$mp3info" && ! type $mp3info >/dev/null 2>/dev/null; then
	echo Note: 192 kbps bitrate won\'t be confirmed becase \"$mp3info\" program is missing.
	mp3info=
    fi
    . $configfile
    rm -f $missing
    update_tags '^t_[0-9]'
    update_tags '^t_[^0-9]' no_tid
else
    echo Autodetecting id3v info:
    for i in *.mp3; do
	$id3v2_list_cmd "$i" >$id3v2_list_tmpfile
	complete=1
	id3v=$(grep -o id3v2 $id3v2_list_tmpfile)
	test "$id3v" || id3v=$(grep -o id3v1 $id3v2_list_tmpfile)
	if test "$id3v" = id3v2; then
	    artist=$(cat $id3v2_list_tmpfile | grep ^TPE1 | cut -f2 -d: | sed -e 's/^ *//')
	    test "$artist" || complete=0
	    album=$(cat $id3v2_list_tmpfile | grep ^TAL | cut -f2 -d: | sed -e 's/^ *//')
	    test "$album" || complete=0
	    genre=$(cat $id3v2_list_tmpfile | grep ^TCON | cut -f2 -d: | perl -ne 'm/\d+/;print $&,"\n"')
	    test "$genre" || complete=0
	    year=$(cat $id3v2_list_tmpfile | grep ^TYE | cut -f2 -d: | sed -e 's/^ *//')
	    test "$year" || complete=0
	elif test "$id3v" = id3v1; then
	    artist=$(cat $id3v2_list_tmpfile | grep -o Artist:.* | cut -f2- -d' ')
	    test "$artist" || complete=0
	    album=$(cat $id3v2_list_tmpfile | grep -o Album.*:. | sed -e 's/[^:]*:.//' -e 's/   *.*//')
	    test "$album" || complete=0
	    genre=$(cat $id3v2_list_tmpfile | grep -o Genre:.* | cut -f2- -d' ')
	    test "$genre" || complete=0
	    year=$(cat $id3v2_list_tmpfile | grep -o Year:..... | cut -f2 -d' ')
	    test "$year" || complete=0
	else
	    complete=0
	fi
	test $complete = 1 && break
    done
    echo "  id3v=$id3v"
    echo "  artist=$artist"
    echo "  album=$album"
    echo "  genre=$genre"
    echo "  year=$year"
    echo
    echo Creating configuration file: $configfile
    echo "# genre: Metal = 9, Soundtrack = 24, Rock = 17" >> $configfile
    echo "# See $program -L for the complete list!" >> $configfile
    echo artist=\"$artist\" >> $configfile
    echo album=\"$album\" >> $configfile
    echo genre=$genre >> $configfile
    echo year=$year >> $configfile
    tracks=$(ls *.mp3 | wc -l | tr -cd 0-9)
    echo tracks=$tracks >> $configfile
    for i in *.mp3; do
	tid=$(echo $i | grep -o '^[0-9]*')
	test "$tid" || tid=$(echo $i | grep -o '[a-zA-Z][a-zA-Z0-9]*' | head -n 1)
	title=$(echo $i | grep -o '[a-zA-Z].*' | sed -e s/\.mp3// | tr A-Z a-z | perl -ne "s/((?<=[^\w.'])|^)./\U\$&/g; print")
	echo "Detected track#=$tid title=$title"
	echo t_$tid=\"$title\" >> $configfile
    done
    echo
    echo Edit $configfile file by hand, and run $0 again.
fi
