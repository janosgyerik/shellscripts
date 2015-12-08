#!/bin/sh
#
# SCRIPT: iptables-simple.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2005-06-18
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Linux only
#
# PURPOSE: Configure a very simple firewall using iptables.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

iptables=/sbin/iptables

log_prefix='iptables-simple.sh: '

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]..."
    echo
    echo Configure a very simple firewall using iptables
    echo
    echo Options:
    echo "      --init         Set default policies and flush chains/tables"
    echo "                       default = $init"
    echo
    echo "      --net NET      Name of the interface connected to internet"
    echo "                       default = $if_net"
    echo "      --lan LAN      Name of the interface connected to intranet"
    echo "                       default = $if_lan"
    echo "      --gw           Create rules to make this host act as gateway"
    echo "                       default = $gw"
    echo
    echo "      --proto PROTO  Select protocols for subsequent filtering rules"
    echo "                       default = $proto_list"
    echo "  -f, --from ADDR    Select addresses for subsequent filtering rules"
    echo "                       default = $addr_list"
    echo "  -p, --port PORT    Select protocols for subsequent filtering rules"
    echo "                       default = $port_list"
    echo
    echo "  -h, --help         Print this help"
    echo "      --doc          Print a more detailed documentation with examples"
    echo
    exit 1
}

doc() {
    cat<<"EOF"
# Effect of --init
# ----------------
# Warning: all the default chains will be flushed!
# INPUT chain:
#	policy: DROP
#	ACCEPT all packets on the loopback interface (lo)
#	ACCEPT RELATED,ESTABLISHED packets
# OUTPUT chain:
#	policy: ACCEPT
# FORWARD chain: 
#	policy: DROP
#
# Effect of --gw
# --------------
# Warning: the nat table will be flushed!
# FORWARD chain:
#	policy: DROP
#	ACCEPT all packets on LAN interface (--lan)
#	ACCEPT RELATED,ESTABLISHED packets on NET interface (--net)
#
# nat table:
#	flush table first
#	POSTROUTING -o $if_net -j MASQUERADE
#	enable packet routing: echo 1 > /proc/sys/net/ipv4/ip_forward
#
# Logging
# -------
# only the INPUT and FORWARD chains
# remove existing LOG rules with $log_prefix
# add LOG rule with $log_prefix
#
# Usage examples
# --------------
# 1. machine is a gateway between local net eth2 and internet eth0
#	$0 --init 
#	$0 --gw --net eth0 --lan eth2
#
# 2. machine serves nfs for local net eth2
#	$0 --init
#	$0 --lan eth2 --proto tcp -p sunrpc -p nfs
#	$0 --lan eth2 --proto tcp -p 612
#	$0 --lan eth2 --proto udp -p sunrpc
#	$0 --lan eth2 --proto udp -p 609
#
# x. save firewall configuration and load later
#	umask 0077
#	iptables-save > /etc/iptables-save.out
#	iptables-restore < /etc/iptables-save.out
#
EOF
    exit
}

args=
#flag=off
#param=
init=off
if_net=
if_lan=
gw=off
proto_list=
addr_list=
port_list=
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    -f|--flag) flag=on ;;
#    -p|--param) shift; param=$1 ;;
    --doc) doc ;;
    --init) init=on ;;
    --net) shift; if_net=$1 ;;
    --lan) shift; if_lan=$1 ;;
    --gw) gw=on ;;
    --proto) shift; proto_list="$proto_list $1" ;;
    -f|--from) shift; addr_list="$addr_list $1" ;;
    -p|--port) shift; port_list="$port_list $1" ;;
    --) shift; for i; do args="$args \"$i\""; done; shift $# ;;
    -?*) echo Unknown option: $1 ; usage ;;
    *) args="$args \"$1\"" ;;
    esac
    shift
done

if ! type $iptables >/dev/null 2>/dev/null; then
    echo Error: program $iptables does not exist. Exit.
    exit 1
fi

if test $init = on; then
    # set default policies
    $iptables -P INPUT DROP
    $iptables -P OUTPUT ACCEPT
    $iptables -P FORWARD DROP

    # flush chains
    $iptables -F INPUT
    $iptables -F OUTPUT
    $iptables -F FORWARD
    
    # reasonable defaults
    $iptables -A INPUT -i lo -j ACCEPT 
    $iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
    $iptables -A INPUT -p icmp -j ACCEPT 
fi

if test $gw = on -a "$if_net" -a "$if_lan"; then
    $iptables -A FORWARD -i $if_lan -j ACCEPT
    $iptables -A FORWARD -i $if_net -m state --state RELATED,ESTABLISHED -j ACCEPT 
    $iptables -t nat -F
    $iptables -t nat -A POSTROUTING -o $if_net -j MASQUERADE
    echo 1 > /proc/sys/net/ipv4/ip_forward
fi

if test "$if_net$if_lan"; then
    if_list="$if_net $if_lan"
else
    if_list=any
fi

test "$addr_list" || addr_list=0.0.0.0/0

# accept packets from specified
#	-> interfaces
#		-> addresses
#			-> ports
for if0 in $if_list; do
    for proto in $proto_list; do
	for addr in $addr_list; do
	    for port in $port_list; do
		$iptables -A INPUT -i $if0 -s $addr -p $proto --dport $port -j ACCEPT 
	    done
	done
    done
done

for chain in INPUT FORWARD; do
    # removing existing logging rules before re-adding
    for num in $($iptables -L $chain --line-numbers | grep "$log_prefix" | cut -f1 -d" " | tac); do
	$iptables -D $chain $num
    done

    # log to kern.info
    $iptables -A $chain -j LOG --log-prefix "$log_prefix" --log-level info
done
