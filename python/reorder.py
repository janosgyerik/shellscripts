#!/usr/bin/env python

from argparse import ArgumentParser
import os


def newname(name, i):
    return '%02d-%s' % (i, name)


def iter_filenames(listfile):
    with open(listfile) as fh:
        for line in fh:
            filename = line.strip()
            if os.path.exists(filename):
                yield filename


def reorder(listfile):
    i = 0
    for filename in iter_filenames(listfile):
        i += 1
        print('mv "%s" "%s"' % (filename, newname(filename, i)))


def main():
    parser = ArgumentParser(
        description='Add numeric prefix to filenames '
                    'to match the order specified in a list file')
    parser.add_argument('listfile',
                        help='file containing filenames in the desired order')
    args = parser.parse_args()

    if os.path.isfile(args.listfile):
        reorder(args.listfile)
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
