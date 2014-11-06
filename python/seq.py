#!/usr/bin/env python

import argparse


def seq(last, first=1, incr=1):
    for num in range(first, last + 1, incr):
        print(str(num))


def main():
    parser = argparse.ArgumentParser(description='Print sequences of numbers, imitating the seq tool')
    parser.add_argument('first', nargs='?', default=1, type=int)
    parser.add_argument('incr', nargs='?', default=1, type=int)
    parser.add_argument('last', type=int)

    args = parser.parse_args()
    seq(args.last, args.first, args.incr)


if __name__ == '__main__':
    main()
