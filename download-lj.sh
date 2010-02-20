#!/bin/sh
#
# SCRIPT: download-lj.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2010-02-20
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: A simple script to download Linux Journal PDFs
#
# REV LIST:
#        DATE:	DATE_of_REVISION
#        BY:	AUTHOR_of_MODIFICATION   
#        MODIFICATION: Describe what was modified, new features, etc-
#
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test "$1" && echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo A simple script to download Linux Journal PDFs
    echo
    echo You need to create a file: $0.config
    echo with the PDF download URL in it, which looks like this:
    echo
    echo https://secure.linuxjournal.com/subs/dl/gaNNNNNN
    echo
    echo You should be able to find this URL in the digital subscribtion emails
    echo sent from Linux Journal every time a new issue is available.
    echo
    echo At the time of this writing, the URL is always the same, and the
    echo latest '(and only the latest)' Linux Journal issue is downloadable
    echo from it without entering a password.
    echo
    echo Options:
    echo
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

portal_url=$(head -n 1 "$0".config 2>/dev/null)
test "$portal_url" || usage

portal_html=$outdir/portal.html
portal_log=$outdir/portal.log
test -d "$outdir" || mkdir -p "$outdir"

msg Downloading portal page ...
wget "$portal_url" -O "$portal_html" -o "$portal_log"

msg Parsing portal page ...
base_url=$(grep ^Location: "$portal_log" | cut -f2 -d' ' | sed -e 's?/pdf/.*??')
pdf_path=$(grep -o '/pdf/.*' "$portal_html" | head -n 1 | sed -e 's/".*//' -e 's/&amp;/\&/g')
pdf_fn=$(grep -o dlj'[0-9]*.pdf' "$portal_html" | head -n 1)

if test -f "$outdir/$pdf_fn"; then
    msg Done: $outdir/$pdf_fn exists, not downloading again.
else
    msg Downloading $pdf_fn ...
    wget "$base_url$pdf_path" -O "$outdir/$pdf_fn" -q
fi

# eof
