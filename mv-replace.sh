#!/bin/sh
#
# SCRIPT: mv-replace.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2004-11-28
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent (Confirmed in: Ubuntu)
#
# PURPOSE: Rename specified files (or files in the current directory) by
#          replacing <pattern> with (possibly empty) <replacement>.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          
#

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... PATTERN [[REPLACEMENT] [FILE]...]"
    echo "Rename specified files (or files in the current directory) by replacing"
    echo "PATTERN with (possibly empty) REPLACEMENT."
    echo
    echo "  -i, --interactive     Prompt before overwrite, default = $interactive"
    echo "  -f, --force           Do not prompt before overwriting, default = $force"
    echo
    echo "  -g, --global          Replace all occurences of pattern, default = $global"
    echo
    echo "  -t, --test            Test only, do not rename, default = $testonly"
    echo
    echo "  -h, --help            Print this help"
    echo
    exit 1
}

args=
#arg=
#flag=off
#param=
interactive=on
force=off
testonly=off
global=off
pattern=
replacement=
replacement_flag=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
    -f|--force) force=on ;;
    -t|--test) testonly=on ;;
    -g|--global) global=on ;;
#    -p|--param) shift; param=$1 ;;
    --) shift
	while [ $# != 0 ]; do 
	    if test "$pattern"; then
		if test $replacement_flag = off; then
		    replacement_flag=on
		    replacement=$1
		else
		    args="$args \"$1\""
		fi
	    else
		pattern=$1
	    fi
	    shift
	done
	break
	;;
    -?*) usage "Unknown option: $1" ;;
    *) 
	if test "$pattern"; then
	    if test $replacement_flag = off; then
		replacement_flag=on
		replacement=$1
	    else
		args="$args \"$1\""
	    fi
	else
	    pattern=$1
	fi
	;;
    esac
    shift
done

test "$pattern" || usage

test "$args" && eval "set -- $args" || set -- *

mv_ops=
test $force = on && mv_ops="$mv_ops -f"
test $interactive = on && mv_ops="$mv_ops -i"

test $global = on && s_flags=g || s_flags=

test $testonly = off && msg= || msg='test: '

for from in "$@"; do
    to=`echo $from | sed -e "s/$pattern/$replacement/$s_flags"`
    if test "$from" != "$to"; then
	echo $msg "\`$from' -> \`$to'"
	test $testonly = off && mv $mv_ops -- "$from" "$to"
    fi
done

# eof
