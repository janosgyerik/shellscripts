#!/usr/bin/python

import subprocess
import re
import sys

if sys.platform != 'darwin':
    sys.stderr.write('This tool is intended for Mac OS X only. '
                     'In Linux use simply "free"!\n')
    sys.exit(1)


def get_rss_total():
    ps_proc = subprocess.Popen(['ps', '-caxm', '-orss,comm'], stdout=subprocess.PIPE)
    ps_out = ps_proc.communicate()[0]
    re_digits_only = re.compile(r'\D+')
    rss_total = 0  # kB
    for line in ps_out.split('\n')[1:]:
        rss = re_digits_only.sub('', line)
        if rss:
            rss_total += float(rss) * 1024
    return rss_total

rssTotal = get_rss_total()


def get_vm_stat():
    vm = subprocess.Popen(['vm_stat'], stdout=subprocess.PIPE).communicate()[0]
    vmLines = vm.split('\n')
    sep = re.compile(':[\s]+')
    vmStats = {}
    for row in range(1, len(vmLines) - 2):
        rowText = vmLines[row].strip()
        rowElements = sep.split(rowText)
        vmStats[(rowElements[0])] = int(rowElements[1].strip('\.')) * 4096
    return vmStats

vmStats = get_vm_stat()


def print_item(label, value):
    print('{:24}{} MB'.format(label + ':', value))


def print_vmstat_item(label, key):
    print_item(label, vmStats[key] / 1024 / 1024)


print_vmstat_item('Wired Memory', 'Pages wired down')
print_vmstat_item('Active Memory', 'Pages active')
print_vmstat_item('Inactive Memory', 'Pages inactive')
print_vmstat_item('Free Memory', 'Pages free')
print_item('Real Mem Total (ps)', '{:.3f}'.format(rssTotal / 1024 / 1024))
