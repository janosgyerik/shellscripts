#!/usr/bin/env bash
#
# SCRIPT: get-checklists.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2014-08-24
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Get checklists from Code Complete
#

set -euo pipefail

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$@"
        exitcode=1
    fi
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Get checklists from Code Complete
    echo
    echo Options:
    echo
    echo "  -h, --help         Print this help"
    echo
    exit $exitcode
}

args=
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

checklists_project=https://github.com/janosgyerik/software-construction-notes

# add a remote called "checklists", pointing to my repo
git remote add checklists $checklists_project

# get the commits of the "master" branch only
git fetch checklists master

# get the "checklists" folder from the "master" branch
git checkout checklists/master checklists

# commit the files in your project
git commit -m 'added checklists files from code complete'
