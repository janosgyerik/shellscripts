#!/usr/bin/env python

import os
import argparse
import re

default_ifs = r'\s+'
default_ofs = r' '

parser = argparse.ArgumentParser(description='transpose columns to lines or lines to columns')
parser.add_argument('files', nargs='+')
parser.add_argument('--ifs', default=default_ifs, help='input field separator')
parser.add_argument('--ofs', default=default_ofs, help='output field separator')
parser.add_argument('--to-cols', action='store_true', help='lines to columns')
parser.add_argument('--lines', type=int, help='number lines to group into columns')

args = parser.parse_args()
ifs = re.compile(args.ifs)
ofs = args.ofs


def for_each_line(fh, fun):
    while True:
        line = fh.readline()
        if not line:
            break
        line = line.strip()
        fun(line)


def columns_to_lines(fh):
    def fun(line):
        for col in ifs.split(line):
            print(col)

    for_each_line(fh, fun)


def lines_to_columns(fh):
    lineno = 0
    needsep = False
    from sys import stdout
    while True:
        line = fh.readline()
        if not line:
            break
        line = line.strip()
        lineno += 1
        if needsep:
            stdout.write(ofs)
        stdout.write(line)
        if lineno % args.lines == 0:
            needsep = False
            stdout.write("\n")
        else:
            needsep = True
    if lineno % args.lines != 0:
        stdout.write("\n")


if args.to_cols:
    fun = lines_to_columns
else:
    fun = columns_to_lines

for path in args.files:
    if path == '-':
        from sys import stdin as fh
    else:
        if not os.path.exists(path):
            print("Path does not exist, skipping: " + path)
            continue
        if not os.path.isfile(path):
            print("Path is not a file, skipping: " + path)
            continue
        fh = open(path)

    fun(fh)
