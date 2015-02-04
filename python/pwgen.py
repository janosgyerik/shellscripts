#!/usr/bin/env python

from __future__ import print_function

import random
import string
import re

from argparse import ArgumentParser

TERMINAL_WIDTH = 80
TERMINAL_HEIGHT = 25

DEFAULT_LENGTH = 12

ALPHABET_DEFAULT = string.ascii_letters + string.digits
ALPHABET_COMPLEX = ALPHABET_DEFAULT + '`~!@#$%^&*()_+-={}[];:<>?,./'
ALPHABET_EASY = re.sub(r'[l1ioO0Z2I]', '', ALPHABET_DEFAULT)

DOUBLE_LETTER = re.compile(r'(.)\1')


def randomstring(alphabet, length=16):
    return ''.join(random.choice(alphabet) for _ in range(length))


def has_double_letter(word):
    return DOUBLE_LETTER.search(word) is not None


def easy_to_type_randomstring(alphabet, length=16):
    while True:
        word = randomstring(alphabet, length)
        if not has_double_letter(word):
            return word


def pwgen(alphabet, easy, length=16):
    get_string = easy_to_type_randomstring if easy else randomstring
    for _ in range(TERMINAL_HEIGHT - 3):
        print(' '.join(get_string(alphabet, length)
                       for _ in range(TERMINAL_WIDTH // (length + 1))))


def main():
    parser = ArgumentParser(description='Generate random passwords')
    parser.add_argument('-a', '--alphabet',
                        help='override the default alphabet')
    parser.add_argument('--complex', action='store_true', default=False,
                        help='use a very complex default alphabet', dest='complex_')
    parser.add_argument('--easy', action='store_true', default=False,
                        help='use a simple default alphabet, without ambiguous or doubled characters')
    parser.add_argument('-l', '--length', type=int, default=DEFAULT_LENGTH)
    args = parser.parse_args()

    alphabet = args.alphabet
    complex_ = args.complex_
    easy = args.easy
    length = args.length

    if alphabet is None:
        if complex_:
            alphabet = ALPHABET_COMPLEX
        elif easy:
            alphabet = ALPHABET_EASY
        else:
            alphabet = ALPHABET_DEFAULT

    pwgen(alphabet, easy, length)


if __name__ == '__main__':
    main()
