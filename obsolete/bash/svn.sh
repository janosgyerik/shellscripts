#!/bin/sh
#
# SCRIPT: svn.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2007-05-23
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Various miscellaneous repository manipulations via svn+ssh:
#	   * remote repository operations:
#		* only with svn+ssh repositories, for path traversal
#		* list projects
#		* checkout projects or update local folder if exists
#			* possible to checkout as bazaar projects
#	   * local copy operations:
#		* show status of local copy
#		* update local copy
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... cmd"
    echo
    echo Perform repository operations on a tree of svn repositories
    echo
    echo "Options:"
    echo "      --ssh SVNHOST SVNROOT   Set the ssh host and svnroot, default = $svnhost $svnroot"
    echo "      --brief                 Brief output, default = $brief"
    echo "  -h, --help                  Print this help"
    echo
    echo "Remote repository commands:"
    echo "  checkout, co"
    echo "  list, ls"
    echo "  bzr - create bazaar projects as branches from svn projects"
    echo
    echo "Local copy commands:"
    echo "  status, stat, st"
    echo "  update, up"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
svnhost=
svnroot=
brief=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    --brief) brief=on ;;
    --ssh)
	test $# -gt 1 || usage
	shift; svnhost=$1
	shift; svnroot=$1 
	;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@

workfile=/tmp/.svn.sh-$$
trap 'rm -f $workfile; exit 1' 1 2 3 15

case $1 in
    checkout|co)
	test "$svnhost" || usage 'Use --ssh to specify svnhost and svnroot!'
	test "$svnroot" || usage 'Use --ssh to specify svnhost and svnroot!'
	test "$2" && localbase=$2 || localbase=.
	ssh $svnhost "find $svnroot -name svnserve.conf" > $workfile
	exec 5<$workfile
	while read f<&5; do
	    rdir=$(dirname $(dirname $f))
	    if test "$rdir" = "$svnroot"; then
		pdir=$localbase/$(basename $rdir)
	    else
		pdir=$localbase/$(echo $rdir | sed -e "s:^$svnroot/::")
	    fi
	    if test -d $pdir; then
		echo "Updating project in $pdir ..."
		echo
		(cd $pdir; svn update)
	    else
		echo "Checking out svn+ssh://$svnhost$rdir into $pdir ..."
		echo
		mkdir -p $(dirname $pdir)
		svn co svn+ssh://$svnhost$rdir $pdir
		echo
	    fi
	done
	;;
    bzr)
	test "$svnhost" || usage 'Use --ssh to specify svnhost and svnroot!'
	test "$svnroot" || usage 'Use --ssh to specify svnhost and svnroot!'
	test "$2" && localbase=$2 || localbase=.
	ssh $svnhost "find $svnroot -name svnserve.conf" > $workfile
	exec 5<$workfile
	while read f<&5; do
	    rdir=$(dirname $(dirname $f))
	    if test "$rdir" = "$svnroot"; then
		pdir=$localbase/$(basename $rdir)
	    else
		pdir=$localbase/$(echo $rdir | sed -e "s:^$svnroot/::")
	    fi
	    if test -d $pdir; then
		echo "Updating project in $pdir ..."
		echo
		(cd $pdir; bzr merge)
	    else
		echo "Checking out svn+ssh://$svnhost$rdir into $pdir ..."
		echo
		mkdir -p $(dirname $pdir)
		bzr co svn+ssh://$svnhost$rdir $pdir
		echo
	    fi
	done
	;;
    list|ls)
	test "$svnhost" || usage 'Use --ssh to specify svnhost and svnroot!'
	test "$svnroot" || usage 'Use --ssh to specify svnhost and svnroot!'
	test "$2" && localbase=$2 || localbase=.
	ssh $svnhost "find $svnroot -name svnserve.conf" | sed -e s:/conf/svnserve.conf::
	;;
    status|stat|st)
	shift
	test "$1" || eval 'set -- .'
	svn_status() {
	    test -d "$1" || return
	    cd "$1"
	    if test -d .svn; then
		tmp1=/tmp/.svn-status-$$-1
		tmp2=/tmp/.svn-status-$$-2
		trap 'rm -f $tmp1 $tmp2; exit 1' 1 2 3 15
		svn info > $tmp1
		revision=r$(grep ^Revision: $tmp1 | sed -e 's/^Revision: //')
		repository=$(grep ^Repository\ Root: $tmp1 | sed -e 's/^[^:]*: //')
		spacing="	"
		printstring="$spacing$revision$spacing$repository"
		svn info | grep ^Revision: > $tmp1
		svn info -rHEAD 2>/dev/null | grep ^Revision: > $tmp2
		if test $? = 0; then
		    if ! cmp $tmp1 $tmp2 > /dev/null; then
			flag1=O
		    else
			flag1=\*
		    fi
		else
		    flag1=\-
		fi
		if test "$(svn stat -q)"; then
		    flag2=M
		else
		    flag2=\*
		fi
		echo "$flag1$flag2$printstring"
		rm -f $tmp1 $tmp2
	    else
		for i in *; do
		    (svn_status $i)
		done
	    fi
	}
	for i in "$@"; do
	    (svn_status $i)
	done
	;;
    update|up)
	shift
	test "$1" || eval 'set -- .'
	svn_up() {
	    test -d "$1" || return
	    cd "$1"
	    if test -d .svn; then
		if test $brief = on; then
		    svn info | grep ^Repository\ Root | cut -f3- -d' '
		    svn up >/dev/null
		else
		    echo -n Local copy:' '
		    pwd
		    svn info | grep ^Repository\ Root
		    svn up
		    echo
		fi
	    else
		for i in *; do
		    (svn_up $i)
		done
	    fi
	}
	for i in "$@"; do
	    (svn_up $i)
	done
	;;
esac

rm -f $workfile
