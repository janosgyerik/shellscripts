#!/bin/sh
#
# SCRIPT: id3tag.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2007-05-04
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Linux, possibly other *NIX
#
# PURPOSE: Rename and tag numbered mp3 files in the current directory based
#          on configuration info in a file named $configfile.
#          If the file is not present, a sample is created automatically,
#          which should be edited by hand appropriately.
#          Declared but missing files will be listed in $missing.
#          If the $mp3info program is present, report files that exist but
#          have other than 192 kbps bitrate in $missing.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

configfile=./.id3tag.sh
program=id3v2
missing=missing
mp3info=mp3info
mp3info_ops=-x
id3v2_list_cmd='id3v2 -l'
id3v2_list_tmpfile=/tmp/.id3tag.sh-$$
trap 'rm -f $id3v2_list_tmpfile' 1 2 3 15

if ! type $program >/dev/null 2>/dev/null; then
    echo You need the $program program to tag mp3 files. Exit.
    exit
fi

usage() {
    echo "Usage: $0 [-h|--help]"
    echo
    echo Set the id3v2 tag of MP3 files in the current directory.
    echo
    echo This program renames and tags numbered mp3 files in the current directory
    echo based on configuration info in a file named "$configfile".
    echo If the file is not present, a sample is created automatically, which
    echo you should edit by hand to define tag information for your mp3s.
    exit
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

if [ -f $configfile ]; then
    if test "$mp3info" && ! type $mp3info >/dev/null 2>/dev/null; then
	echo Note: 192 kbps bitrate won\'t be confirmed becase \"$mp3info\" program is missing.
	mp3info=
    fi
    . $configfile
    rm -f $missing
    for i in `seq -f "%02g" 1 $tracks`; do
	j=${i#0}
	v=\$t_$j
	tj=`eval echo $v`
	test "$tj" || tj="Track $i"
	filename="$i - $tj.mp3"
	if test ! -f "$filename"; then
	    match=`ls *$i* 2>/dev/null | head -1`
	    test -f "$match" && mv "$match" "$filename"
	fi
	if test -f "$filename"; then
	    extra=
	    if test "$mp3info"; then
		if ! $mp3info $mp3info_ops "$filename" | grep "192 kbps" >/dev/null 2>/dev/null; then
		    extra="( not 192 kbps, >> $missing )"
		    echo $filename "*** not 192 kbps ***" >> $missing
		fi
	    fi
	    echo Tagging \"$filename\" ... $extra
	    $program --artist "$artist" --song "$tj" --album "$album" --genre "$genre" --year "$year" --track $j/$tracks "$filename" > /dev/null
	else
	    echo Missing \"$filename\" ... "( >> $missing )"
	    echo $filename >> $missing
	fi
    done
    for i in "99 - "*; do
	test -f "$i" || continue
	echo Tagging \"$i\" ...
	$program --artist "$artist" --album "$album" --genre "$genre" --year "$year" --track 99 "$i" > /dev/null
    done
else
    echo Autodetecting id3v info:
    for i in *mp3; do
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
    echo \# genre: Metal = 9, Soundtrack = 24, Rock = 17 >> $configfile
    echo \# See $program -L for the complete list! >> $configfile
    echo artist=\"$artist\" >> $configfile
    echo "album=\"$album\"" >> $configfile
    echo genre=$genre >> $configfile
    echo year=$year >> $configfile
    tracks=`ls | grep -i \.mp3$ | wc -l`
    echo tracks=$tracks >> $configfile
    for i in `seq 1 $tracks`; do
	echo -n .
	number=`printf %02d $i`
	title=`ls "$number - "*.mp3 2>/dev/null`
	if test "$title"; then
	    title=`expr "$title" : '.. - \(.*\).mp3'`
	    title=`echo "$title" | tr A-Z a-z | perl -ne "s/((?<=[^\w.'])|^)./\U\$&/g; print"`
	fi
	echo t_$i=\"$title\" >> $configfile
    done
    echo
    echo Now edit this file by hand, and run $0 again.
fi

# eof
