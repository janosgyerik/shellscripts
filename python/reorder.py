#!/usr/bin/env python

from optparse import OptionParser
import os


def newname(name, i):
    return '%02d-%s' % (i, name)


def reorder(listfile):
    i = 0
    with open(listfile) as fh:
        for line in fh:
            filename = line.strip()
            if os.path.exists(filename):
                i += 1
                print('mv "%s" "%s"' % (filename, newname(filename, i)))


def main():
    parser = OptionParser()
    parser.set_usage('%prog [options] LISTFILE...')
    '''
    parser.add_option('-r', '--regex', action='store_true', default=False,
            help='use regular expressions to find matching files')
    '''
    parser.set_description('Add numeric prefix to filenames to match order specified in a list file')
    (options, args) = parser.parse_args()

    if args:
        for listfile in args:
            if os.path.isfile(listfile):
                reorder(listfile)
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
