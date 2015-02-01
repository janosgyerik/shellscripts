#!/usr/bin/env python

from __future__ import print_function
import json

from argparse import ArgumentParser


def prettyprint(fh, indent):
    print(json.dumps(json.load(fh), indent=indent))


def main():
    parser = ArgumentParser(description='Pretty-print JSON')
    parser.add_argument('-i', '--indent', type=int,
                        help='width of indent level')
    parser.add_argument('files', nargs='*')
    args = parser.parse_args()

    indent = args.indent

    if args.files:
        for path in args.files:
            with open(path) as fh:
                prettyprint(fh, indent)
    else:
        import sys

        prettyprint(sys.stdin, indent)


if __name__ == '__main__':
    main()
