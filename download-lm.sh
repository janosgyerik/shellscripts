#!/bin/sh
#
# SCRIPT: download-lm.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2010-05-02
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Download Linux Magazine PDFs from your digital subscription
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test "$1" && echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Download Linux Magazine PDFs from your digital subscription
    echo
    echo You need to create a file: $0.config
    echo with your account username and password in it like this:
    echo
    echo user=user@example.com
    echo pass=yourpass
    echo
    echo Options:
    echo "  -d, --dir PATH        Path to the output directory, default = $outdir"
    echo
    echo "  -h, --help            Print this help"
    echo
    exit 1
}

msg() {
    echo '* '$@
}

args=
#arg=
#flag=off
#param=
outdir=.
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -d|--dir) shift; outdir=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"

#test -f "$1" || usage

if ! test -f "$0".config; then
    msg Error: config file does not exist
    msg Create $0.config with:
    msg user=user@example.com
    msg pass=yourpass
    exit 1
fi
. "$0".config

if ! test "$user" -a "$pass"; then
    msg Error: '$user' or '$pass' not defined in the config file
    msg Edit $0.config with:
    msg user=user@example.com
    msg pass=yourpass
    exit 1
fi

issue_url=https://www.linux-magazine.com/w3/ezdigital/issue
portal_url=https://www.linux-magazine.com/w3/ezdigital/issue/index_html
portal_html=$outdir/portal.html
portal_log=$outdir/portal.log
test -d "$outdir" || mkdir -p "$outdir"

msg Downloading portal page ...
wget "$portal_url" -O "$portal_html" -o "$portal_log" --user="$user" --password="$pass"

if ! test -s "$portal_html"; then
    msg Error: The portal page is empty. This is a problem.
    exit 1
fi

msg Parsing portal page ...
grep -o '[0-9][0-9]*/Linux_Magazine_Issue_[0-9][0-9]*\.pdf' $portal_html | while read pdf_url; do
    pdf_fn=$(echo $pdf_url | cut -f2 -d/)
    if ! test -s "$outdir"/$pdf_fn; then
	msg downloading $pdf_fn ...
	wget "$issue_url"/$pdf_url -O "$outdir"/$pdf_fn --user="$user" --password="$pass" -q
    fi
done

msg Done

# eof
