Shell scripts
=============
Convenient shell scripts for everyday use, written in bash, perl, awk, python.

All scripts print a helpful usage message when used with `-h` or `--help`

The `./install.sh` script will symlink these scripts in your `~/bin`
directory. It will not overwrite any existing files.

## Bash

* bash/bak.sh

    Move or copy files and directories with .bak or .YYYYMMDD suffix

* bash/bell.sh

    Sound the system bell

* bash/capitalize.sh

    Capitalize words in filenames

* bash/col.sh

    Extract the n-th column of stdin

* bash/cp-replace.sh

    Replace regex patterns in filenames

* bash/csv2csv.sh

    Convert CSV to CSV using specified locale

* bash/demoronizer.sh

    Convert non-ascii characters to ascii (rough) equivalents

* bash/dos2unix.sh

    Remove carriage return from files

* bash/ebook-convert.sh

    TODO

* bash/eggtimer.sh

    Countdown from specified minutes and seconds

* bash/extract-audio-from-video.sh

    Extract audio content from video files

* bash/extract-icon-from-platter.sh

    Extract an icon image from a platter of icon images

* bash/find-recent.sh

    Find and sort files by atime/ctime/mtime

* bash/flac2mp3.sh

    Convert FLAC files to MP3 using flac and lame

* bash/gen-indexhtml.sh

    Generate index.html from files and directory trees

* bash/get-checklists.sh

    Get checklists from Code Complete

* bash/git.sh

    Perform repository operations on a tree of Git repositories

* bash/icons2dim.sh

    Resize icon images to have specified width and height

* bash/icons2square.sh

    Pad images with transparency to have equal width and height

* bash/iconv-filenames.sh

    Convert the encoding of filenames (if possible)

* bash/id3tag.sh

    Set id3 v2 tag on mp3 files in the current directory and rename nicely

* bash/ipod2local.sh

    Import mp3 files from ipod to hard disk

* bash/iptables-simple.sh

    Configure a very simple firewall using iptables

* bash/jar-manifest-classpath.sh

    Print the classpath entries of the manifest of JAR files

* bash/java-io-tmpdir.sh

    Print the value of java.io.tmpdir

* bash/lowercase.sh

    Rename files to all lowercase letters

* bash/m4a2mp3.sh

    Convert M4A files to MP3 using faad and bladeenc

* bash/mv-many.sh

    Rename files and directories by editing their names in vim

* bash/mv-replace.sh

    Replace regex patterns in filenames

* bash/my-external-ip.sh

    Find my external IP address

* bash/my-ip.sh

    Print my local IP address

* bash/paths.sh

    Transform the display of path strings

* bash/pdf-pages.sh

    Cut out a range of pages from PDF files

* bash/pwgen.sh

    Generate random alphanumeric passwords

* bash/quote.sh

    Enclose each line of input within quotes

* bash/rip-audiocd.sh

    Copy titles in an audio CD to wav files in the specified directory

* bash/rip-dvd.sh

    Rip a DVD movie into a high quality DIVX file

* bash/save-webpage.sh

    Save a webpage and all the files necessary to display properly

* bash/screenshot.sh

    Take a screenshot of the entire screen or a window

* bash/ssh-authorizeme.sh

    Add a public key to the authorized_keys file on a remote server

* bash/ssh-tunnel-keeper.sh

    Create an ssh rtunnel and try to keep it alive as long as possible

* bash/sys-vitalbackup-Linux.sh

    Backup most vital system files and most relevant system information

* bash/template-html.sh

    Create a standards compliant HTML skeleton

* bash/template-perl.sh

    Generate a Perl script template with a simple argument parser

* bash/template-sh.sh

    Generate a Bash script template with a simple argument parser

* bash/unrar.sh

    Properly unrar files in directories containing spaces in their names

* bash/uppercase.sh

    Rename files to all uppercase letters

* bash/wav2mp3.sh

    Convert WAV files to MP3 using bladeenc or lame

* bash/wma2mp3.sh

    Convert WAV files to MP3 using mplayer, and bladeenc or lame

* bash/words.sh

    Find words in specified files or directories

* bash/wp-config-to-my-cnf.sh

    Create a MySQL my.cnf file from a WordPress configuration file

## Perl

* perl/atime.pl

    Print access time of specified files

* perl/base64.pl

    Encode (= default) or decode Base64

* perl/pie.pl

    Apply expression on the content of files, for example s/foo/bar/g

## Awk

* awk/avg.awk

    Compute the average of numeric values on stdin

* awk/column.awk

    Columnate lists, imitating the BSD `column -t` command

* awk/lengths.awk

    Compute and print the lengths of lines on stdin

* awk/max.awk

    Compute the minimum of numeric values on stdin

* awk/min.awk

    Compute the minimum of numeric values on stdin

* awk/sum.awk

    Compute the sum of numeric values on stdin

* awk/var.awk

    Compute the variance of numeric values on stdin

## Python

* python/fakedate.py

    Print the current date but with specified values overridden

* python/free.py

    Display amount of free and used memory in the system

* python/iconv.py

    Convert the character encoding of files

* python/paste.py

    Merge corresponding or subsequent lines of files

* python/pp.py

    Pretty-print JSON

* python/pwgen.py

    Generate random passwords

* python/renum.py

    Add numeric prefix to filenames to match the order specified in a list file

* python/seq.py

    Print sequences of numbers, imitating the seq tool

* python/titlecase.py

    Rename files to "titlecased" and "sanitized"

* python/transpose.py

    Convert columns to lines or lines to columns

* python/xpath.py

    Test on an XML file an XPATH expression

