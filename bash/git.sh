#!/bin/sh
#
# SCRIPT: git.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
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
    echo "      --fetch                 do 'git fetch'"
    echo
    echo "  -h, --help                  Print this help"
    echo
    echo "Commands:"
    echo "  list                        List repositories"
    echo "  pending                     Show repositories with possible pending changes"
    echo "  outdated                    Show repositories that are out of date"
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
fetch=off
#param=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
    --fetch) fetch=on ;;
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

repolist() {
    for dir; do
        dir="$dir" perl << "END"
use File::Find;
find(\&wanted, $ENV{dir});
sub wanted {
    if (-d "$_/.git") {
        $File::Find::prune = 1;
        print $File::Find::dir, "/$_\n";
        return;
    }
}
END
    done
}

command=$1; shift

print_heading() {
    if ! test "$printed_heading"; then
        echo Repo: $repo
        printed_heading=1
    fi
}

warn() {
    print_heading
    warnings=1
    echo '  [W]' $*
}

case $command in
    list)
        repolist "$@"
        ;;
    pending)
        for dir; do
            test -d "$dir" || continue
            for repo in $(repolist "$dir"); do
                printed_heading=
                warnings=
                pending=
                (cd $repo; git remote | grep -x origin >/dev/null) || warn 'origin not defined'
                (cd $repo; grep remote.*=.*origin .git/config >/dev/null) || warn 'origin not set as upstream; git branch --set-upstream-to origin/master'
                (cd $repo; git symbolic-ref HEAD | grep -x -e refs/heads/master -e refs/heads/gh-pages >/dev/null) || warn 'not on master or gh-pages'
                (cd $repo; git status | grep 'Your branch is ahead of' >/dev/null) && warn 'ahead of tracked branch'
                (cd $repo; git status | grep 'Changes to be committed' >/dev/null) && warn 'staged but uncommitted changes' && pending=1
                (cd $repo; git status | grep 'Changes not staged' >/dev/null) && warn 'unstaged pending changes' && pending=1
                (cd $repo; git status | grep 'Untracked files' >/dev/null) && warn 'untracked files' && pending=1
                test "$pending" || (cd $repo; git status | grep 'working directory clean' >/dev/null) || warn 'other (??) pending changes'
                test "$printed_heading" && echo
            done
        done
        ;;
    outdated)
        repolist "$@" | while read repo; do
            printed_heading=
            test $fetch = on && GIT_DIR=$repo/.git git fetch origin >/dev/null 2>/dev/null
            behind=$(GIT_DIR="$repo"/.git git status | sed -ne 's/.* behind .* by \([0-9]*\) commit.*/\1/p')
            test "$behind" && warn "behind by $behind commit(s)"
            test "$printed_heading" && echo
        done
        ;;
    *) usage ;;
esac
    
# eof
