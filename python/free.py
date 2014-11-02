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


def get_vmstats():
    vmstat_out = subprocess.Popen(['vm_stat'], stdout=subprocess.PIPE).communicate()[0]
    re_key_value = re.compile(r'([^:]+).*?(\d+)')
    vmstats = {}
    for line in vmstat_out.split('\n'):
        m = re_key_value.match(line)
        if m:
            key, value = m.groups()
            vmstats[key] = int(value) * 4096
    return vmstats


def print_item(label, value):
    print('{:24}{} MB'.format(label + ':', value))


def print_vmstat_item(vmstats, label, key):
    print_item(label, vmstats[key] / 1024 / 1024)


def main():
    vmstats = get_vmstats()
    print_vmstat_item(vmstats, 'Wired Memory', 'Pages wired down')
    print_vmstat_item(vmstats, 'Active Memory', 'Pages active')
    print_vmstat_item(vmstats, 'Inactive Memory', 'Pages inactive')
    print_vmstat_item(vmstats, 'Free Memory', 'Pages free')
    print_vmstat_item(vmstats, 'Swapins', 'Swapouts')
    rss_total = get_rss_total()
    print_item('Real Mem Total (ps)', '{:.3f}'.format(rss_total / 1024 / 1024))

if __name__ == '__main__':
    main()
