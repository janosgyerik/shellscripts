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
# PURPOSE: Download Linux Journal PDFs from your digital subscription
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
    echo Download Linux Journal PDFs from your digital subscription
    echo
    echo You need to create a file: $0.config
    echo with the PDF download URL in it, which looks like this:
    echo
    echo http://download.linuxjournal.com/pdf/dl.php?key=gaNNNNNN
    #echo https://secure.linuxjournal.com/subs/dl/gaNNNNNN
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
    echo "  -v, --verbose         Verbose output, useful for debugging, default = $verbose"
    echo "  -h, --help            Print this help"
    echo
    exit 1
}

msg() {
    echo '* '$@
}

err() {
    echo Error: $*
    exit 1
}

args=
#arg=
#flag=off
#param=
outdir=.
verbose=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -v|--verbose) verbose=on ;;
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

do_wget() {
    dst=$1; shift
    test $verbose = on && echo wget -O "$dst" $*
    wget -O "$dst" $*
    if ! test -s "$dst"; then
	rm -f "$dst"
	err downloaded empty file: $dst
    fi
    test $verbose = on && ls -l "$dst"
}

test $verbose = on && wget_ops= || wget_ops=-q

msg Downloading portal page ...
do_wget "$portal_html" "$portal_url" $wget_ops

msg Parsing portal page ...
base_url=$(echo $portal_url | sed -e 's?^\(http://[^/]*\)/.*?\1?')
pdf_path=$(sed -ne 's?^.*/pdf/?/pdf/? p' "$portal_html" | head -n 1 | sed -e 's/".*//' -e 's/&amp;/\&/g')
pdf_fn=$(echo $pdf_path | sed -ne 's/.*\(dlj.*.pdf\).*/\1/ p')

pdf_out="$outdir/$pdf_fn"
if test ! -s "$pdf_out"; then
    msg Downloading $pdf_fn ...
    do_wget "$pdf_out" "$base_url$pdf_path" $wget_ops
fi

# eof
