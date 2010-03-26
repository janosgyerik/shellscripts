#!/bin/sh
#
# SCRIPT: bzr.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2008-05-03
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Manipulate a tree of bzr repositories at once:
#	   * remote repository operations:
#		* only with bzr+ssh repositories, for path traversal
#		* list projects
#		* checkout projects or update local folder if exists
#	   * local copy operations:
#		* show status of local copy
#		* update local copy
#	   * note:
#		* as of 2.0.4, there is seems to be no way to distinguish 
#		  between an unmodified local copy with a local copy that has
#		  local commits. This becomes a problem when updating local
#		  copies with local commits. When updating a local copy with
#		  local commits, the changes in local commits, the changes
#		  made after that, and the changes in the repository will all
#		  blend together. That is, the local changes made after the
#		  local commits will be extremely difficult to see.
#		  The workaround to this is to not keep around uncommitted
#		  changes in a working directory that has local commits.
#		  FYI, this behavior affects both update and checkout commands,
#		  as they both automatically update existing repositories.
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
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... cmd"
    echo "Manipulate a tree of bzr repositories at once"
    echo
    echo "Options:"
    echo "      --ssh BZRHOST BZRROOT   Set the ssh host and bzrroot, default = $bzrhost $bzrroot"
    echo "      --brief                 Brief output, default = $brief"
    echo "      --local                 Run commands in local mode, default = $local"
    echo "      --test                  Run in test mode, default = $testmode"
    echo "  -h, --help                  Print this help"
    echo
    echo "Commands:"
    echo "  checkout, co                Checkout remote repo tree"
    echo "  localco, lco                Checkout local repo tree"
    echo "  list, ls                    Show list of repos in remote repo tree"
    echo "  locallist, lls              Show list of repos in local repo tree"
    echo "  diff                        Show differences between local and remote tree"
    echo "  push                        Push local repo tree to remote location"
    echo "  bind                        Bind to corresponding remote locations"
    echo "  status, stat, st            Show status of local repo tree"
    echo "  update, up                  Update local repo tree"
    echo "  cleanse, cl                 Remove .~1~ files created by bzr"
    echo
    exit 1
}

normalpath() {
    echo $1 | sed -e 's?//*?/?g' -e 's?/*$??'
}

args=
#arg=
#flag=off
#param=
bzrhost=
bzrroot=
brief=off
local=off
testmode=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    --brief) brief=on ;;
    --local) local=on ;;
    --dry-run|--test) testmode=on ;;
    --ssh)
	test "$2" -a "$3" || usage
	shift; bzrhost=$1
	shift; bzrroot=$(normalpath "$1")
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

workfile=/tmp/.bzr.sh-$$
trap 'rm -f $workfile; exit 1' 1 2 3 15

repolistcmd() {
    echo "find -L $1 -name .bzr | sed -e s:/.bzr:: | sort | awk -v prev=0 '\$0 !~ prev { print; prev=\$0 }'"
}

case "$1" in
    checkout|co)
	test "$bzrhost" || usage 'Use --ssh to specify bzrhost and bzrroot!'
	test "$bzrroot" || usage 'Use --ssh to specify bzrhost and bzrroot!'
	test "$2" && localbase=$(normalpath "$2") || localbase=.
	ssh $bzrhost "$(repolistcmd $bzrroot)" | while read rdir; do
	    if test "$rdir" = "$bzrroot"; then
		pdir=$localbase/$(basename $rdir)
	    else
		pdir=$localbase/$(echo $rdir | sed -e "s:^$bzrroot/::")
	    fi
	    if test -d $pdir; then
		echo "Updating project in $pdir ..."
		echo
		(cd $pdir; bzr update)
	    else
		echo "Checking out bzr+ssh://$bzrhost$rdir into $pdir ..."
		echo
		if test $testmode = on; then
		    echo '(test mode, skipping)'
		else
		    mkdir -p $(dirname $pdir)
		    bzr co bzr+ssh://$bzrhost$rdir $pdir
		fi
	    fi
	done
	;;
    localco|lco)
	test "$2" && localrepo=$(normalpath "$2") || localrepo=$PWD
	eval "$(repolistcmd $localrepo)" | while read line; do
	    if ! ls "$line" | grep . >/dev/null; then
		echo Local checkout: $line
		test $testmode = on && echo '(test mode, skipping)' || (cd "$line"; bzr co)
		echo
	    fi
	done
	;;
    list|ls)
	test "$bzrhost" || usage 'Use --ssh to specify bzrhost and bzrroot!'
	test "$bzrroot" || usage 'Use --ssh to specify bzrhost and bzrroot!'
	ssh $bzrhost "$(repolistcmd $bzrroot)"
	;;
    locallist|lls)
	test "$2" && localrepo=$(normalpath "$2") || localrepo=$PWD
	eval "$(repolistcmd $localrepo)"
	;;
    diff)
	test "$bzrhost" || usage 'Use --ssh to specify bzrhost and bzrroot!'
	test "$bzrroot" || usage 'Use --ssh to specify bzrhost and bzrroot!'
	test "$2" && localrepo=$(normalpath "$2") || localrepo=$PWD
	ssh $bzrhost "$(repolistcmd $bzrroot)" | sed -e "s?$bzrroot??" > $workfile
	eval "$(repolistcmd $localrepo)" | sed -e "s?$localrepo??" | diff -u - $workfile
	;;
    status|stat|st)
	shift
	test "$1" || eval 'set -- .'
	bzr_status() {
	    test -d "$1" || return
	    dd="$1"
	    test "$2" && pp="$pp/$dd" || pp="$dd"
	    cd "$1"
	    if test -d .bzr; then
		revno=$(bzr revno)
		repo=$(bzr info | grep 'checkout of branch:' | sed -e 's/^[^:]*: //')
		test "$repo" && checkout=1 || checkout=0
		test $checkout = 0 && repo=standalone:$pp
		tab="	"
		if bzr diff >/dev/null 2>/dev/null; then
		    test "$(bzr st 2>/dev/null | head -n 1)" && f1=\? || f1=\*
		    if test $local = on -o $checkout = 0; then
			f2=-
		    else
			bzr info -v >/dev/null 2>/dev/null && f2= || f2=E 
			if test ! "$f2"; then
			    bzr info -v | grep -F 'Branch is out of date' >/dev/null && f2=O || f2=\*
			fi
		    fi
		else
		    f1=M
		    f2=-
		fi
		echo "$f1$f2$tab"r"$revno$tab$repo"
	    else
		for i in *; do
		    (bzr_status $i $pp)
		done
	    fi
	}
	for i in "$@"; do
	    (bzr_status $i)
	done
	;;
    update|up)
	shift
	test "$1" || eval 'set -- .'
	bzr_up() {
	    test -d "$1" || return
	    cd "$1"
	    if test -d .bzr; then
		if test $brief = on; then
		    bzr info | sed -e '/checkout of / p' -e d | sed -e 's/.*branch: \(.*\)/\1/'
		    bzr up >/dev/null
		else
		    echo -n Local copy:' '
		    pwd
		    bzr info | grep -F 'checkout of branch'
		    bzr up
		    echo
		fi
	    else
		for i in *; do
		    (bzr_up $i)
		done
	    fi
	}
	for i in "$@"; do
	    (bzr_up $i)
	done
	;;
    cleanse|cl)
	shift
	test "$1" || eval 'set -- .'
	for i in "$@"; do
	    find "$i" -name '*.~?~' -exec rm -v {} \;
	done
	;;
    push)
	test "$bzrhost" || usage 'Use --ssh to specify bzrhost and bzrroot!'
	test "$bzrroot" || usage 'Use --ssh to specify bzrhost and bzrroot!'
	shift
	test "$1" || eval 'set -- .'
	bzr_push() {
	    test -d "$1" || return
	    test "$2" && path=$2/ || path=
	    cd "$1"
	    if test -d .bzr; then
		target=bzr+ssh://$bzrhost/$bzrroot/$path$1
		echo Push source: $PWD
		echo Push target: $target
		test $testmode = on && echo '(test mode, skipping)' || bzr push $target --create-prefix
		echo
	    else
		for i in *; do
		    (bzr_push $i $path$1)
		done
	    fi
	}
	for i in "$@"; do
	    (bzr_push $(normalpath "$i"))
	done
	;;
    bind)
	test "$bzrhost" || usage 'Use --ssh to specify bzrhost and bzrroot!'
	test "$bzrroot" || usage 'Use --ssh to specify bzrhost and bzrroot!'
	shift
	test "$1" || eval 'set -- .'
	bzr_bind() {
	    test -d "$1" || return
	    test "$2" -a "$2" != . && path=$2/ || path=
	    cd "$1"
	    if test -d .bzr; then
		target=bzr+ssh://$bzrhost/$bzrroot/$path$1
		echo Local repo: $PWD
		echo Bind target: $target
		if test $testmode = on; then
		    echo '(test mode, skipping)'
		else
		    bzr bind $target || {
			echo Local repo: $PWD
			echo Bind target: $target
			echo
		    } >&2
		fi
		echo
	    else
		for i in *; do
		    (bzr_bind $i $path$1)
		done
	    fi
	}
	for i in "$@"; do
	    (bzr_bind $(normalpath "$i"))
	done
	;;
    *) usage ;;
esac

rm -f $workfile
    
# eof
