#!/usr/bin/env python

import os
import codecs
import argparse

DEFAULT_ENCODING = 'utf-8'


def iconv_file(path, fromcode, tocode):
    tmp = path + '.tmp'
    with codecs.open(path, 'r', fromcode) as sourceFile:
        with codecs.open(tmp, 'wb', tocode) as targetFile:
            targetFile.write(sourceFile.read())
            os.rename(tmp, path)


def main():
    parser = argparse.ArgumentParser(description='Convert the character encoding of files')
    parser.add_argument('-f', '--from-code', default=DEFAULT_ENCODING)
    parser.add_argument('-t', '--to-code', default=DEFAULT_ENCODING)
    parser.add_argument('paths', nargs='+')

    args = parser.parse_args()

    for path in args.paths:
        if os.path.isfile(path):
            iconv_file(path, args.from_code, args.to_code)


if __name__ == '__main__':
    main()
