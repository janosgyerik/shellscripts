#!/usr/bin/env python

import argparse


def seq(last, first=1, incr=1, equalize_widths=False):
    if equalize_widths:
        template = '{:0%dd}' % len(str(last))
    else:
        template = '{}'
    for num in range(first, last + 1, incr):
        yield template.format(num)


def print_seq(*args, **kwargs):
    for item in seq(*args, **kwargs):
        print(item)


def main():
    parser = argparse.ArgumentParser(description='Print sequences of numbers, imitating the seq tool')
    parser.add_argument('first', nargs='?', default=1, type=int)
    parser.add_argument('incr', nargs='?', default=1, type=int)
    parser.add_argument('last', type=int)
    parser.add_argument('-w', dest='equalize_widths', help='Equalize widths', action='store_true', default=False)

    args = parser.parse_args()
    print_seq(args.last, first=args.first, incr=args.incr, equalize_widths=args.equalize_widths)


if __name__ == '__main__':
    main()
