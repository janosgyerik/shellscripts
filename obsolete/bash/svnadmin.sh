#!/bin/sh
#
# SCRIPT: svnadmin.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2007-09-06
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Subversion repository tool based on svnadmin to operate on many
#	   repositories in a subdirectory tree.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

svnadmin=
if type svnadmin >/dev/null 2>/dev/null; then
    svnadmin=svnadmin
else
    searchpath='/usr/local/bin'
    for dir in $searchpath; do
	if test -x $dir/svnadmin; then
	    svnadmin=$dir/svnadmin
	    break
	fi
    done
    if test ! "$svnadmin"; then
	echo Cannot locate svnadmin command in $searchpath! Exit.
	exit 1
    fi
fi

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Subversion repository tool based on svnadmin
    echo
    echo "  -s, --source SOURCE  default = $source"
    echo "  -t, --target TARGET  default = $target"
    echo "  -d, --dump           default = $dump"
    echo "  -l, --load           default = $load"
    echo
    echo "  -y, --yes            yes to all questions, default = $yes"
    echo "  -v, --verbose        default = $yes"
    echo
    echo "  -h, --help           Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
source=
target=
dump=off
load=off
yes=off
verbose=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -s|--source) shift; source=$1 ;;
    -t|--target) shift; target=$1 ;;
    -d|--dump) dump=on ;;
    -l|--load) load=on ;;
    -y|--yes) yes=on ;;
    -v|--verbose) verbose=on ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

#test $# -gt 0 || usage
test "$source" || usage

dumpfilename=svnadmin.dump

ok_to_erase() {
    test "$1" || return 1
    test -e "$1" || return 0
    test $yes = on && return 0
    echo -n Ok to erase \'$target\'?' [yN] '
    read ans
    case $ans in
	[yY]*) ans=0;;
	*) ans=1;;
    esac
    return $ans
}

if test "$target" && ok_to_erase "$target"; then
    rm -fr "$target"
    mkdir -p "$target"
fi

if test $dump = on; then
    find "$source" -type f -name uuid | sed -e "s?^$source/*??" -e 's?/db/uuid$??' | while read repo; do
	echo '* detected repository: 'SOURCE/$repo
	if test "$target"; then
	    dir=$target/$repo
	    echo '* dumping to '$dir/$dumpfilename ...
	    mkdir -p $dir
	    $svnadmin dump $source/$repo > $dir/$dumpfilename
	fi
    done
elif test $load = on; then
    find "$source" -type f -name $dumpfilename | sed -e "s?^$source/*??" | while read repodumpfile; do
	echo '* detected dumpfile: 'SOURCE/$repodumpfile
	if test "$target"; then
	    repo=$target/$(dirname $repodumpfile)
	    repobase=$(dirname $repo)
	    echo '* creating repo '$repo ...
	    mkdir -p $repobase
	    $svnadmin create $repo
	    if test $verbose = on; then
		$svnadmin load $repo < $source/$repodumpfile
	    else
		$svnadmin load $repo < $source/$repodumpfile >/dev/null
	    fi
	fi
    done
else
    usage 'You must specify some action to take, such as dump or load!'
fi
