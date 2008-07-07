#!/bin/sh
#
# Print out the IP address of your machine.
#

/sbin/ifconfig | grep ^eth0 -A1 | tail -1 | awk '{print $2}' | cut -f2 -d:
