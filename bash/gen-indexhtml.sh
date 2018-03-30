#!/usr/bin/env bash
#
# SCRIPT: gen-index.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2016-04-23
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Generate index.html from files and directory trees
#          Give a clear, and if necessary, long, description of the
#          purpose of the shell script. This will also help you stay
#          focused on the task at hand.
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
    echo Generate index.html from files and directory trees
    echo
    echo Options:
    echo "  -r, --recursive            default = $recursive"
    echo "      --no-recursive         default = ! $recursive"
    echo "  -n, --dry-run              default = $dryrun"
    echo "      --no-dry-run           default = ! $dryrun"
    echo
    echo "  -h, --help                 Print this help"
    echo
    exit $exitcode
}

args=
recursive=off
dryrun=off
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
    -r|--recursive) recursive=on ;;
    --no-recursive) recursive=off ;;
    -n|--dry-run) dryrun=on ;;
    --no-dry-run) dryrun=off ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test $# != 0 || usage "Error: specify target directories"

gen_header() {
    basename=${PWD##*/}
    cat << EOF
<!DOCTYPE html>
<html>
    <head>
        <title>Index of $basename</title>
    </head>
    <body>
        <h1>Index of $basename</h1>
        <hr>
EOF
}

gen_footer() {
    cat << EOF
        <hr>
        <i>Generated on $(date) by $(basename "$0")</i>
    </body>
</html>
EOF
}

gen_link() {
    name=${1#./}
    name=${name%/}
    test "$name" == index.html && return
    test -d "$name" && name="$name/"
    printf '        <p><a href="%s">%s</a></p>\n' "$name" "$name"
}

gen_indexhtml_cwd() {
    {
        gen_header
        for path; do
            gen_link "$path"
        done
        gen_footer
    } | output
}

gen_indexhtml_subdirs() {
    for path; do
        if test -d "$path"; then
            (cd "$path"; gen_indexhtml ./*)
        fi
    done
}

gen_indexhtml() {
    gen_indexhtml_cwd "$@"
    if test $recursive = on; then
        gen_indexhtml_subdirs "$@"
    fi
}

output() {
    if test $dryrun = on; then
        cat
    else
        cat > index.html
    fi
}

gen_indexhtml "$@"
