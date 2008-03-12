#!/bin/sh
#
# SCRIPT: backup.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2005-02-20
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Given a base directory BASE, copy files under 
#          BASE/sources/{daily,weekly,monthly}
#          into
#          BASE/archives/{daily,weekly,monthly}
#          with a name tag to reflect the current {day,week,month}.
#          To be executed {daily,weekly,monthly} 
#          with the flags {--daily,--weekly,--monthly}
#
# REV LIST:
#        DATE:	DATE_of_REVISION
#        BY:	AUTHOR_of_MODIFICATION   
#        MODIFICATION: Describe what was modified, new features, etc-
#
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script
#          

rcfile=~/.backup-sh.rc

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]..."
    echo
    echo "Archive files under BASE/sources/{daily,weekly,monthly}"
    echo "              into BASE/archives/{daily,weekly,monthly}"
    echo "Optionally, upload new archives to URL/archives/{daily,weekly,monthly}"
    echo
    echo "  --base BASE   The base directory of source and archive files."
    echo "                Can be defined in $rcfile with base=BASE"
    echo "  --url URL     The base url to upload new archive files."
    echo "                Can be defined in $rcfile with url=URL"
    echo
    echo "  --daily       Perform on BASE/sources/daily"
    echo "  --weekly      Perform on BASE/sources/weekly"
    echo "  --monthly     Perform on BASE/sources/monthly"
    echo
    echo "  --init        mkdir BASE/{sources,archives}/{daily,weekly,monthly}"
    echo "  --initftp     mkdir URL/{sources,archives}/{daily,weekly,monthly}"
    echo
    echo "  -h, --help    Print this help"
    echo
    exit 1
}

neg=0
base=
url=
test -f $rcfile && . $rcfile
dir=
nametag=
init=off
initftp=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    !) neg=1; shift; continue ;;
    --base) shift; base=$1 ;;
    --url) shift; url=$1 ;;
    --init) test $neg = 1 && init=off || init=on ;;
    --initftp) test $neg = 1 && initftp=off || initftp=on ;;
    --daily) dir=daily; nametag=$(date +%a) ;;
    --weekly) dir=weekly; d=$(date +%d) ;;
    --monthly) dir=monthly; nametag=$(date +%b) ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; done; shift; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) usage ;;
    esac
    shift
done

test "$base" || usage "Error: you must specify BASE. Exit."

test $init = on && mkdir -vp $base/{sources,archives,latest}/{daily,weekly,monthly}

# load SSH_* environmental variables
test -f ~/.ssh/.env && . ~/.ssh/.env
# if connection to the ssh agent could NOT be established, disable ftp options
if ! ssh-add -L >/dev/null 2>&1 ; then 
    initftp=off
    url=
fi

if test $initftp = on; then
    test "$url" || usage "Error: you must specify URL. Exit."
    for u in $url; do
	# u=username@host:path
	url_host=$(expr $u : '\([^:]*\)')
	url_path=$(expr $u : '[^:]*:\(.*\)')
	ssh $url_host "mkdir -vp $url_path/{archives,latest}/{daily,weekly,monthly}"
	scp $base/archives/daily/* $u/archives/daily
	scp $base/archives/weekly/* $u/archives/weekly
	scp $base/archives/monthly/* $u/archives/monthly
    done
fi

test -d $base/sources -a "$dir" || exit 1

dir_s=$base/sources/$dir
dir_a=$base/archives/$dir
dir_l=$base/latest/$dir

for i in $(ls $dir_s); do
    latest=$dir_l/$i
    if test -f $latest && cmp $latest $dir_s/$i >/dev/null 2>&1 ; then continue; fi
    base=$(expr $i : '\(.*\)\.')
    ext=$(expr $i : '.*\.\(.*\)')
    newfile=
    case $ext in
	tgz|tbz) newfile=$base.$nametag.$ext ;;
	gz|bz2) 
	    tarless=$(expr $base : '\(.*\)\.tar$')
	    if test "$tarless"; then
		base=$tarless
		ext=tar.$ext
	    fi
	    newfile=$base.$nametag.$ext
	    ;;
	"") newfile=$base.$nametag ;;
	*) newfile=$base.$nametag.$ext ;;
    esac
    cp $dir_s/$i $dir_a/$newfile
    ln -snf $dir_a/$newfile $latest
    rm -f $dir_s/$i
    if test "$url"; then
	for u in $url; do
	    url_host=$(expr $u : '\([^:]*\)')
	    url_path=$(expr $u : '[^:]*:\(.*\)')
	    scp $dir_a/$newfile $u/archives/$dir/$newfile
	    ssh $url_host "ln -snf $url_path/archives/$dir/$newfile $url_path/latest/$dir/$i"
	done
    fi
done

# eof
