#!/usr/bin/env bash

if test $# -lt 2; then
    echo "Usage: $0 minutes seconds [message]"
    echo
    echo Countdown from specified minutes and seconds
    exit 1
fi

min=$1
sec=$2
message=$3
test "$message" || message='done'

((target_time = $(date +%s) + min * 60 + sec))
while :; do
    ((current_time = $(date +%s)))
    ((current_time >= target_time)) && break
    ((remain_sec_total = target_time - current_time))
    ((remain_min = remain_sec_total / 60))
    ((remain_sec = remain_sec_total % 60))
    printf '%4d:%02d  \r' $remain_min $remain_sec
    sleep 1
done

printf '%-7s\n' "$message"
