#!/bin/sh
#
# SCRIPT: template-html.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-06-11
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent (Confirmed in: Linux, FreeBSD, Solaris 10)
#
# PURPOSE: Create a standards compliant HTML skeleton.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test $# = 0 || echo "$@"
    echo "Usage: $0 [OPTION]... FILENAME"
    echo
    echo Create a standards compliant HTML skeleton
    echo
    echo "      --dtd transitonal | strict | html4   default = $dtd"
    echo "  -c, --charset CHARSET            default = $charset"
    echo "  -t, --title TITLE                "
    echo "  -k, --keywords KEYWORDS          "
    echo "      --description DESCRIPTION    "
    echo "  -a, --author AUTHOR              "
    echo "  -s, --style STYLE                "
    echo "  -r, --refresh REFRESH            "
    echo
    echo "  -h, --help                       Print this help"
    echo
    exit 1
}

args=
#flag=off
#param=
dtd_html4='<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
dtd_transitional='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
dtd_strict='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
dtd=strict
charset='utf-8'
title=
keywords=
description=
author=
style=
refresh=
file=
date=$(date +%F)
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    --dtd) shift; dtd=$1 ;;
    -c|--charset) shift; charset=$1 ;;
    -t|--title) shift; title=$1 ;;
    -k|--keywords) shift; keywords=$1 ;;
    --description) shift; description=$1 ;;
    -a|--author) shift; author=$1 ;;
    -s|--style) shift; style="<link rel=\"stylesheet\" type=\"text/css\" href=\"$1\" />" ;;
    -r|--refresh) shift; refresh="<meta http-equiv=\"Refresh\" content=\"$1\" />" ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) file=$1 ;;
    esac
    shift
done

test "$file" || usage

case $dtd in 
    h*|html4) dtd=$dtd_html4 ;;
    t*|transitional) dtd=$dtd_transitional ;;
    s*|strict) dtd=$dtd_strict ;;
    *) dtd=$dtd_strict ;;
esac

cat << EOF > "$file"
$dtd
<!--$dtd_html4-->
<!--$dtd_transitional-->
<!--$dtd_strict-->
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=$charset" />
    <!--<meta http-equiv="Refresh" content="0; http://www.google.com" />-->
    $refresh
    <meta name="keywords" content="$keywords" />
    <meta name="description" content="$description" />
    <meta name="DC.description" content="$description" />
    <meta name="DC.Creator" content="$author" />
    <meta name="DC.date.created" content="$date" />
    <meta name="DC.date.modified" content="$date" />
    <meta name="DC.type" content="Document" />
    <meta name="DC.format" content="text/plain" />

    <!--<link rel="stylesheet" type="text/css" href="filename.css" />-->
    $style
    <!--<script type="text/javascript" src="filename.js"></script>-->
    <title>$title</title>
  </head>

  <body>
  </body>
</html>
EOF
