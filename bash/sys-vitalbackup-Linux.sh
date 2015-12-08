#!/bin/sh
#
# SCRIPT: sys-vitalbackup-Linux.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-05-07
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Linux only
#
# PURPOSE: This program takes a backup of important statistics, configuration
#          files and other files.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#          

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]..."
    echo
    echo Backup most vital system files and most relevant system information
    echo
    echo "  -f, --file FILE       Save tarball in FILE"
    echo "      --light           Save less information, default = $light"
    echo
    echo "  -h, --help            Print this help"
    echo
    exit 1
}

#flag=off
#param=
light=off
file=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    --light) light=on ;;
    -f|--file) shift; file=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
#    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
    *) usage ;;
    esac
    shift
done

OSNAME=$(uname -s)
HOSTNAME=$(hostname)
VERSION=$(uname -r)
tmpdir=$OSNAME-$HOSTNAME-$VERSION
test $light = on && tmpdir=$tmpdir-light
test "$file" || file=$tmpdir.tar.gz

trap 'rm -fr $file $tmpdir; exit 1' 1 2 3 15

mkdir -p $tmpdir

if [ $light = off ]; then
    echo "* saving /etc preserving permissions ..."
    tar cf - /etc | tar xpf - -C $tmpdir
    echo "* saving /boot ..."
    cp -RL /boot $tmpdir/boot
else
    echo "* saving _some_ files in /etc preserving permissions ..."
    tar cf - $(du -sk /etc/* | awk '$1 < 300 {print $2}') /etc/init.d | tar xpf - -C $tmpdir
fi

echo "* saving /proc info ..."
w=$tmpdir/proc
mkdir $w
for i in cmdline cpufreq cpuinfo crypto devices diskstats dma execdomains fb filesystems interrupts iomem ioports loadavg locks mdstat meminfo misc modules mounts mtrr partitions stat swaps sysrq-trigger uptime version vmstat; do
    test -f /proc/$i && cat /proc/$i > $w/$i
done

echo "* saving the output of some commands ..."
w=$tmpdir/out
mkdir $w
dmesg > $w/dmesg
cp /var/log/dmesg $w/var-log-dmesg
lspci -v > $w/lspci-v
lsmod > $w/lsmod
iptables -L > $w/iptables-L
netstat -na > $w/netstat-na

echo "* tgz-ing it all up in $file ..."
tar cf - $tmpdir | gzip -c > $file

echo "* cleaning up ..."
rm -fr $tmpdir

echo "* done."
