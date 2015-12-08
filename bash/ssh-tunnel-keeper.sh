#!/bin/sh
#
# SCRIPT: ssh-tunnel-keeper.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-08-17
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Create an ssh rtunnel and try to keep it alive as long as possible
#          by fine-tuned ssh client options and by restarting it whenever it
#          becomes unusable (dies or "just stops working").
#	   IMPORTANT: "autossh" is a program that does the same thing this
#	   script is trying to do, and it does it better. Use this script
#	   only if you cannot use "autossh". 
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
    echo Create an ssh rtunnel and try to keep it alive as long as possible
    echo Note: if you can, you should use autossh instead.
    echo
    echo Options:
    echo "  -l, --lport LPORT  "
    echo "      --rport RPORT  "
    echo "      --rhost RHOST  "
    echo
    echo "  -h, --help         Print this help"
    echo
    exit 1
}

args=
#flag=off
#param=
lport=
rport=
rhost=
timeout_keeperkill=3
delay_tester=300
timeout_tester=5
ssh_banner=SSH-
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -l|--lport) shift; lport=$1 ;;
    --rport) shift; rport=$1 ;;
    --rhost) shift; rhost=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
#    *) args="$args \"$1\"" ;;
    *) usage ;;
    esac
    shift
done

eval "set -- $args"

test "$lport" -a "$rport" -a "$rhost" || usage

ssh $rhost perl -MSocket -e print >/dev/null 2>/dev/null || { echo "The perl modle Socket does not exist on $rhost. Exit."; exit; }

pid_ssh_file=/tmp/.ssh-tunnel-keeper.sh-1-$$
work2=/tmp/.ssh-tunnel-keeper.sh-2-$$
trap 'rm -f $pid_ssh_file $work2; exit 1' 1 2 3 15

while :; do
    echo "$(date): Starting tunnel $rport:localhost:$lport $rhost ..."
    ssh -N -o BatchMode=yes -R $rport:localhost:$lport $rhost &
    pid_ssh=$!
    echo $pid_ssh > $pid_ssh_file
    # in case THIS script itself is terminated, clean up the ssh child process
    trap 'rm -f $pid_ssh_file; kill -HUP $pid_ssh || kill -KILL $pid_ssh; exit 1' 1 2 3 15
    wait $pid_ssh
    echo "$(date): Tunnel exited, restarting soon ..."
    # give time to program exit (Ctrl-C, or kill $0, when exiting this script)
    sleep $timeout_keeperkill
done &

while :; do
    # check the connection by grabbing the SSH banner
    { ssh $rhost "perl -MSocket -e '\$proto = getprotobyname(\"tcp\"); socket(SH, PF_INET, SOCK_STREAM, \$proto); \$sin = sockaddr_in($rport, inet_aton(\"127.0.0.1\")); connect(SH, \$sin); \$banner = <SH>; exit (\$banner =~ m/^$ssh_banner/ ? 0 : 1)'" && echo 0 || echo 1; } > $work2 &
    # give time to tester to terminate, if it does
    sleep $timeout_tester

    if ps -p $! >/dev/null 2>/dev/null; then
	echo "$(date): Tunnel is down. (Tester still did not terminate)"
	kill -9 $!
    elif test "$(cat $work2)" != 0; then
	echo "$(date): Tunnel is down. (Tester returned nonzero)"
    else
	# good, tester terminated, and it exited with 0
	continue
    fi
    # bad, tester did not return 0
    echo "$(date): Killing keeper to restart in next cycle."
    kill -9 $(cat $pid_ssh_file)
    # give time to ssh child to restart
    sleep $delay_tester
done
