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
    echo "  -h, --help                  Print this help"
    echo
    echo "Commands:"
    echo "  list                        List repositories"
    echo "  pending                     Show repositories with possible pending changes"
    echo "  behind                      Show repositories that are behind"
    echo "  fetch                       Do 'git fetch origin'"
    echo "  pull                        Do 'git pull'"
    echo
    exit 1
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

repo_start() {
    repo_heading_printed=
}

repo_end() {
    test "$repo_heading_printed" && echo
}

repo_heading() {
    if ! test "$repo_heading_printed"; then
        echo Repo: $repo
        repo_heading_printed=1
    fi
}

warn() {
    repo_heading
    echo '  [W]' $*
}

_git() {
    GIT_DIR="$repo"/.git GIT_WORK_TREE="$repo" git $*
}

case $command in
    list)
        repolist "$@"
        ;;
    pending)
        repolist "$@" | while read repo; do
            repo_start
            pending=
            _git remote | grep -x origin >/dev/null || warn 'origin not defined'
            #(cd $repo; grep remote.*=.*origin .git/config >/dev/null) || warn 'origin not set as upstream; git branch --set-upstream-to origin/master'
            _git symbolic-ref HEAD | grep -x -e refs/heads/master -e refs/heads/gh-pages >/dev/null || warn 'not on master or gh-pages'
            _git status | grep 'Your branch is ahead of' >/dev/null && warn 'ahead of tracked branch'
            _git status | grep 'Changes to be committed' >/dev/null && warn 'staged but uncommitted changes' && pending=1
            _git status | grep 'Changes not staged' >/dev/null && warn 'unstaged pending changes' && pending=1
            _git status | grep 'Untracked files' >/dev/null && warn 'untracked files' && pending=1
            test "$pending" || _git status | grep 'working directory clean' >/dev/null || warn 'other (??) pending changes'
            repo_end
        done
        ;;
    behind)
        repolist "$@" | while read repo; do
            repo_start
            behind=$(_git status | sed -ne 's/.* behind .* by \([0-9]*\) commit.*/\1/p')
            diverged=$(_git status | grep diverged)
            test "$behind" && warn "behind by $behind commit(s)"
            test "$diverged" && warn "diverged from origin"
            repo_end
        done
        ;;
    fetch)
        repolist "$@" | while read repo; do
            repo_start
            repo_heading
            _git fetch origin >/dev/null 2>/dev/null
            repo_end
        done
        ;;
    pull)
        repolist "$@" | while read repo; do
            repo_start
            repo_heading
            (cd "$repo" && git pull)
            repo_end
        done
        ;;
    *) usage ;;
esac
    
# eof
