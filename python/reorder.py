#!/usr/bin/env python

from optparse import OptionParser
import os
# import re


def newname(name, i):
    # todo: format controls
    return '%02d-%s' % (i, name)


def matching(files, pattern):
    # todo: matching logic control: regex, case insensitive
    return [x for x in files if x == pattern]
    # return [x for x in files if x.endswith(pattern)]
    # return [x for x in files if re.search(pattern, x)]


def reorder(path, listfile):
    files = os.listdir(path)
    patterns = [x.strip() for x in listfile.readlines()]
    i = 0
    for pattern in patterns:
        for name in matching(files, pattern):
            if os.path.exists(name):
                i += 1
                print('mv "%s" "%s"' % (name, newname(name, i)))


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
        for path in args:
            if os.path.isfile(path):
                reorder('.', open(path))
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
