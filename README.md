Shell scripts
=============
Convenient shell scripts for everyday use, written in bash, perl, awk, python.

All scripts print a helpful usage message when used with `-h` or `--help`

The `./install.sh` script will symlink these scripts in your `~/bin`
directory. It will not overwrite any existing files.

## Bash

* bash/add-stub-pl.sh

    Insert a script header after the first line of a perl script

* bash/add-stub-sh.sh

    Insert a script header after the first line of a shell script

* bash/add-usage-sh.sh

    Add a usage() function after the first blank line of a shell script

* bash/alert.sh

    Sound the system bell

* bash/backup.sh

    Archive files under BASE/sources/{daily,weekly,monthly}

* bash/bak.sh

    Move or copy files and directories with .bak or .YYYYMMDD suffix

* bash/bzr.sh

    Perform repository operations on a tree of bzr repositories

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

* bash/download-lj.sh

    Download Linux Journal PDFs from your digital subscription

* bash/download-lm.sh

    Download Linux Magazine PDFs from your digital subscription

* bash/eggtimer.sh

    Countdown from specified minutes and seconds

* bash/extract-icon-from-platter.sh

    Extract an icon image from a platter of icon images

* bash/find-recent.sh

    Find and sort files by atime/ctime/mtime

* bash/flac2mp3.sh

    Convert FLAC files to MP3 using flac and lame

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

    TODO

* bash/java-io-tmpdir.sh

    Print the value of java.io.tmpdir

* bash/lowercase.sh

    Rename files to all lowercase letters

* bash/m4a2mp3.sh

    Convert M4A files to MP3 using faad and bladeenc

* bash/mv-replace.sh

    Replace regex patterns in filenames

* bash/my-external-ip.sh

    Find my external IP address

* bash/my-ip.sh

    Print my local IP address

* bash/pdf-pages.sh

    Cut out a range of pages from PDF files

* bash/quote.sh

    Enclose each line of input within quotes

* bash/rip-audiocd.sh

    Copy titles in an audio CD to wav files in the specified directory

* bash/rip-dvd.sh

    Rip a DVD movie into a high quality DIVX file

* bash/save-flash-linux.sh

    Copy a flash movie (youtube.com, etc) saved by a browser in /private

* bash/save-flash-mac.sh

    Copy a flash movie (youtube.com, etc) saved by a browser in /private

* bash/save-webpage.sh

    Save a webpage and all the files necessary to display properly

* bash/screenshot.sh

    Take a screenshot of the entire screen or a window

* bash/ssh-authorizeme.sh

    Add a public key to the authorized_keys file on a remote server

* bash/ssh-tunnel-keeper.sh

    Create an ssh rtunnel and try to keep it alive as long as possible

* bash/svn.sh

    Perform repository operations on a tree of svn repositories

* bash/svnadmin.sh

    Subversion repository tool based on svnadmin

* bash/sys-vitalbackup-Linux.sh

    Backup most vital system files and most relevant system information

* bash/template-html.sh

    Create a standards compliant HTML skeleton

* bash/template-perl.sh

    Generate a Perl script template with a simple argument parser

* bash/template-sh.sh

    Generate a /bin/sh script template with a simple argument parser

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

## Perl

* perl/FreeBSD.pl

    A package manager for FreeBSD emulating some of the functionality of apt-get

* perl/atime.pl

    Print access time of specified files

* perl/base64.pl

    Encode (= default) or decode Base64

* perl/dbi-info.pl

    Print the list of available DBI drivers and data sources

* perl/geoip-lookup.pl

    Find the country of a hostname or IP address using Geo::IPfree

## Awk

* awk/avg.awk

    Compute the average of numeric values in the input files or pipe

* awk/max.awk

    Find the maximum numeric value in the input files or pipe

* awk/min.awk

    Find the minimum numeric value in the input files or pipe

* awk/sum.awk

    Compute the sum of numeric values in the input files or pipe

* awk/var.awk

    Compute the variance of numeric values in the input files or pipe

## Python

* python/fakedate.py

    Print the current date but with specified values overridden

* python/free.py

    Display amount of free and used memory in the system

* python/iconv.py

    Convert the character encoding of files

* python/paste.py

    merge corresponding or subsequent lines of files

* python/pp.py

    Pretty-print JSON

* python/pwgen.py

    Generate random passwords

* python/reorder.py

    Add numeric prefix to filenames to match the order specified in a list file

* python/seq.py

    Print sequences of numbers, imitating the seq tool

* python/titlecase.py

    Rename files to "titlecased" and "sanitized"

* python/transpose.py

    convert columns to lines or lines to columns

* python/xpath.py

    TODO

