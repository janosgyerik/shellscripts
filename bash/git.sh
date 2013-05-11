#!/bin/sh
#
# SCRIPT: git.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2013-05-11
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Perform repository operations on a tree of Git repositories
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... COMMAND DIR..."
    echo
    echo "Perform repository operations on a tree of Git repositories"
    echo
    echo "Options:"
    echo "  -h, --help                  Print this help"
    echo
    echo "Commands:"
    echo "  list                        List repositories"
    echo "  pending                     Show repositories with possible pending changes"
    echo
    exit 1
}

fatal() {
    echo Fatal: "$@"
    exit 1
}

normalpath() {
    echo $1 | sed -e 's?//*?/?g' -e 's?/*$??'
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

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@

repolistcmd() {
    python - <<END
import os
for path, dirs, files in os.walk('$1'):
    if '.git' in dirs:
        del dirs[:]
        print path
END
}

command=$1; shift

case $command in
    list)
        for dir; do
            test -d "$dir" || continue
            for repo in $(repolistcmd "$dir"); do
                echo $repo
            done
        done
        ;;
    pending)
        warn() {
            if ! test "$printed_heading"; then
                echo Repo: $repo
                printed_heading=1
            fi
            warnings=1
            echo '  [W]' $*
        }
        for dir; do
            test -d "$dir" || continue
            for repo in $(repolistcmd "$dir"); do
                printed_heading=
                warnings=
                pending=
                (cd $repo; git remote | grep -x origin >/dev/null) || warn 'origin not defined'
                (cd $repo; grep remote.*=.*origin .git/config >/dev/null) || warn 'origin not set as upstream; git branch --set-upstream master origin/master'
                (cd $repo; git symbolic-ref HEAD | grep -x refs/heads/master >/dev/null) || warn 'not on master branch'
                (cd $repo; git status | grep 'Your branch is ahead of' >/dev/null) && warn 'ahead of tracked branch'
                (cd $repo; git status | grep 'Changes to be committed' >/dev/null) && warn 'staged but uncommitted changes' && pending=1
                (cd $repo; git status | grep 'Changes not staged' >/dev/null) && warn 'unstaged pending changes' && pending=1
                (cd $repo; git status | grep 'Untracked files' >/dev/null) && warn 'untracked files' && pending=1
                test "$pending" || (cd $repo; git status | grep 'working directory clean' >/dev/null) || warn 'other (??) pending changes'
                test "$printed_heading" && echo
            done
        done
        ;;
    *) usage ;;
esac
    
# eof
