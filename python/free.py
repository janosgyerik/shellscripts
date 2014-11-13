#!/usr/bin/python

import subprocess
import re
import sys
import argparse

if sys.platform != 'darwin':
    sys.stderr.write('This tool is intended for Mac OS X only. '
                     'In Linux use simply "free"!\n')
    sys.exit(1)


def get_rss_total():
    ps_proc = subprocess.Popen(
        ['ps', '-caxm', '-orss,comm'], stdout=subprocess.PIPE)
    ps_out = ps_proc.communicate()[0]
    re_digits_only = re.compile(r'\D+')
    rss_total = 0  # kB
    for line in ps_out.split('\n'):
        rss = re_digits_only.sub('', line)
        if rss:
            rss_total += int(rss) * 1024
    return rss_total


def get_vmstats():
    vmstat_out = subprocess.Popen(
        ['vm_stat'], stdout=subprocess.PIPE).communicate()[0]
    re_key_value = re.compile(r'([^:]+).*?(\d+)')
    vmstats = {}
    for line in vmstat_out.split('\n'):
        match = re_key_value.match(line)
        if match:
            key, value = match.groups()
            vmstats[key] = int(value) * 4096
    return vmstats


def print_free_stats():
    vmstats = get_vmstats()

    def print_vmstat_item(label, key):
        print('{:24}{:8} MB'.format(label + ':', vmstats[key] / 1024 / 1024))

    print_vmstat_item('Wired Memory', 'Pages wired down')
    print_vmstat_item('Active Memory', 'Pages active')
    print_vmstat_item('Inactive Memory', 'Pages inactive')
    print_vmstat_item('Free Memory', 'Pages free')
    rss_total = get_rss_total()
    vmstats['total'] = rss_total
    print_vmstat_item('Real Mem Total (ps)', 'total')


def main():
    parser = argparse.ArgumentParser(
        description='Display amount of free and used memory in the system')
    parser.parse_args()

if __name__ == '__main__':
    main()
