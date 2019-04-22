#!/usr/bin/env python

from argparse import ArgumentParser, ArgumentTypeError
import os
import re

re_numeric_prefix = re.compile(r'^[0-9]+ *- *')


def newname(i, name):
    """
    >>> newname(1, 'foo')
    '01 - foo'
    >>> newname(2, 'bar')
    '02 - bar'
    >>> newname(22, 'baz')
    '22 - baz'
    >>> newname(123, 'foobar')
    '123 - foobar'
    >>> newname(1, '01-foo')
    '01 - foo'
    >>> newname(1, '01 - foo')
    '01 - foo'
    """
    stripped = re_numeric_prefix.sub('', name)
    return '{:02d} - {}'.format(i, stripped)


def iter_filenames(listfile):
    with open(listfile) as fh:
        for line in fh:
            filename = line.strip()
            if os.path.exists(filename):
                yield filename


def renum(listfile, start):
    i = start
    for filename in iter_filenames(listfile):
        print('mv "%s" "%s"' % (filename, newname(i, filename)))
        i += 1


def main():
    def positive_int(value):
        ivalue = int(value)
        if ivalue <= 0:
            raise ArgumentTypeError("%s is an invalid positive int value" % value)
        return ivalue

    parser = ArgumentParser(
        description='Add numeric prefix to filenames '
                    'to match the order specified in a list file')
    parser.add_argument(
        'listfile', help='file containing filenames in the desired order')
    parser.add_argument('-s', '--start', type=positive_int, default=1, help='start value of the counter')
    args = parser.parse_args()

    if os.path.isfile(args.listfile):
        renum(args.listfile, args.start)
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
