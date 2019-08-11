#!/usr/bin/env bash
#
# SCRIPT: rewrite-git-commit-dates.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2019-08-11
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Rewrite the commit dates of a range of Git commits
#

set -euo pipefail

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$*" >&2
        exitcode=1
    fi
    cat << EOF
Usage: $0 [OPTION]...

Rewrite the commit dates of a range of Git commits

Options:
  -f, --start-commit REVISION         Required. Current setting = $start_commit
  -s, --start-date YYYY-MM-DD-hh      Required. Current setting = $start_date
  -e, --end-date YYYY-MM-DD-hh        Required. Current setting = $end_date

  -h, --help                          Print this help

EOF
    exit "$exitcode"
}

args=()
start_commit=
start_date=
end_date=
while [[ $# != 0 ]]; do
    case $1 in
    -h|--help) usage ;;
    -f|--start-commit) shift; start_commit=$1 ;;
    -s|--start-date) shift; start_date=$1 ;;
    -e|--end-date) shift; end_date=$1 ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) usage "Unexpected argument: $1" ;;
    esac
    shift
done

fatal() {
    echo "fatal: $*" >&2
    exit 1
}

error() {
    echo "error: $*" >&2
}

validate_commit() {
    local rev=$1
    git rev-parse -q --verify "$rev" &>/dev/null || fatal "not a valid commit: $rev"
}

validate_date() {
    local date_spec=$1
    [[ "$date_spec" =~ ^[1-9][0-9]{3}-[01][0-9]-[0123][0-9]-[012][0-9]$ ]] || fatal "string does not appear to be a date in YYYY-MM-DD-hh format: $date_spec"
}

ready=1
if ! [[ "$start_commit" ]]; then
    ready=
    error "Required parameter missing: start commit. Specify it using -f REVISION"
fi
if ! [[ "$start_date" ]]; then
    ready=
    error "Required parameter missing: start date. Specify it using -s YYYY-MM-DD-hh"
fi
if ! [[ "$end_date" ]]; then
    ready=
    error "Required parameter missing: end date. Specify it using -e YYYY-MM-DD-hh"
fi

[[ "$ready" ]] || exit 1

validate_commit "$start_commit"
validate_date "$start_date"
validate_date "$end_date"

ellipsize() {
    awk '{ len = length($0); if (len < 75) print; else print substr($0, 1, 74) " [...]"; }'
}

summarize_commits() {
    git log --format='%h %ai %ci %s' "$start_commit"...HEAD | ellipsize
}

date_to_epoch() {
    local date_str=$1
    python -c "from datetime import datetime as dt; print(str(dt.strptime('$date_str', '%Y-%m-%d-%H').timestamp())[:-2])"
}

distributed_dates() {
    local start=$1
    local delta=$2
    local n=$3
    local i segment ts
    local ts_inc_list=()

    ((segment = delta / n))
    for ((i = 0; i < n; i++)); do
        ((ts = start + RANDOM % segment))
        ((start += segment))
        ts_inc_list+=($ts)
    done

    # print timestamps in reverse order
    for ((i = n - 1; i >= 0; i--)); do
        echo "${ts_inc_list[i]}"
    done
}

rewrite_git_commit_dates() {
    local start_date_epoch=$(date_to_epoch "$start_date")
    local end_date_epoch=$(date_to_epoch "$end_date")
    local delta commits ts i
    ((delta = end_date_epoch - start_date_epoch))

    mapfile -t commits < <(git rev-list "$start_commit"..HEAD)
    local n=${#commits[@]}
    mapfile -t ts < <(distributed_dates "$start_date_epoch" "$delta" "$n")

    local LF=$'\n'
    local cmds="case \$GIT_COMMIT in$LF"
    for ((i = 0; i < n; i++)); do
        cmds+="${commits[i]}) export GIT_AUTHOR_DATE=${ts[i]}; export GIT_COMMITTER_DATE=${ts[i]} ;;$LF"
    done
    cmds+=esac

    git filter-branch -f --env-filter "$cmds" "$start_commit"..HEAD
}

echo "Original commits:"
summarize_commits | sed -e 's/^/  /'
echo

rewrite_git_commit_dates 

echo "Rewritten commits:"
summarize_commits | sed -e 's/^/  /'
echo
