#!/usr/bin/env bash
#
# SCRIPT: alert.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2010-05-01
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Linux, Mac OS X, possibly Solaris
#
# PURPOSE: Sound the system bell
#

set -euo pipefail

usage() {
    echo "Usage: $0"
    echo
    echo "Sound the system bell"
    exit
}

[ $# = 0 ] || usage

echo $'\a' | tr -d '\n'
