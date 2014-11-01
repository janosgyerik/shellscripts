#!/usr/bin/python

import subprocess
import re
import sys

if sys.platform != 'darwin':
    sys.stderr.write('This tool is intended for Mac OS X only. '
                     'In Linux use simply "free"!\n')
    sys.exit(1)

# Get process info
ps = subprocess.Popen(['ps', '-caxm', '-orss,comm'],
                      stdout=subprocess.PIPE).communicate()[0]
vm = subprocess.Popen(['vm_stat'], stdout=subprocess.PIPE).communicate()[0]

# Iterate processes
processLines = ps.split('\n')
sep = re.compile('[\s]+')
rssTotal = 0  # kB
for row in range(1, len(processLines)):
    rowText = processLines[row].strip()
    rowElements = sep.split(rowText)
    try:
        rss = float(rowElements[0]) * 1024
    except:
        rss = 0  # ignore...
    rssTotal += rss

# Process vm_stat
vmLines = vm.split('\n')
sep = re.compile(':[\s]+')
vmStats = {}
for row in range(1, len(vmLines) - 2):
    rowText = vmLines[row].strip()
    rowElements = sep.split(rowText)
    vmStats[(rowElements[0])] = int(rowElements[1].strip('\.')) * 4096


def print_item(label, value):
    print('{:24}{} MB'.format(label + ':', value))


def print_vmstat_item(label, key):
    print_item(label, vmStats[key] / 1024 / 1024)

print_vmstat_item('Wired Memory', 'Pages wired down')
print_vmstat_item('Active Memory', 'Pages active')
print_vmstat_item('Inactive Memory', 'Pages inactive')
print_vmstat_item('Free Memory', 'Pages free')
print_item('Real Mem Total (ps)', '{:.3f}'.format(rssTotal / 1024 / 1024))
