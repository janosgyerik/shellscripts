#!/usr/bin/env python

import argparse
from itertools import chain
from sys import stdin

import re

DEFAULT_IFS = r'\s+'
DEFAULT_OFS = '\t'


def transpose(buffer):
    """
    >>> transpose([])
    []
    >>> transpose([['a', 'b', 'c']])
    [['a'], ['b'], ['c']]
    >>> transpose([['a'], ['b'], ['c']])
    [['a', 'b', 'c']]

    :param buffer: the data to transpose
    :return: transposed buffer: columns converted to lines or lines converted to columns
    """
    if not buffer:
        return buffer

    if len(buffer) > 1:
        return [list(chain.from_iterable(buffer))]

    return [[line] for line in buffer[0]]


def parse_content(fh, ifs):
    return [ifs.split(line.strip()) for line in fh]


def read_content(path, ifs):
    if path == '-':
        return parse_content(stdin, ifs)
    else:
        with open(path) as fh:
            return parse_content(fh, ifs)


def print_content(buffer, ofs):
    if not buffer:
        return

    if len(buffer) > 1:
        for line in chain.from_iterable(buffer):
            print(line)
    else:
        print(ofs.join(buffer[0]))


def main():
    parser = argparse.ArgumentParser(description='convert columns to lines or lines to columns')
    parser.add_argument('path')
    parser.add_argument('--ifs', default=DEFAULT_IFS, help='input field separator (used to extract columns)')
    parser.add_argument('--ofs', default=DEFAULT_OFS, help='output field separator (used to print columns)')
    parser.add_argument('--lines', type=int, help='number lines to group into columns')

    args = parser.parse_args()
    path = args.path
    ifs = re.compile(args.ifs)
    ofs = args.ofs

    print_content(transpose(read_content(path, ifs)), ofs)

if __name__ == '__main__':
    main()
