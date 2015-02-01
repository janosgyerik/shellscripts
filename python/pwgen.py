#!/usr/bin/env python

from __future__ import print_function

import random
import string
import re

from argparse import ArgumentParser

terminal_width = 80
terminal_height = 25

default_length = 12

alphabet_default = string.ascii_letters + string.digits
alphabet_complex = alphabet_default + '`~!@#$%^&*()_+-={}[];:<>?,./'
alphabet_easy = re.sub(r'[l1ioO0Z2I]', '', alphabet_default)

double_letter = re.compile(r'(.)\1')


def randomstring(alphabet, length=16):
    return ''.join(random.choice(alphabet) for _ in range(length))


def has_double_letter(word):
    return double_letter.search(word) is not None


def easy_to_type_randomstring(alphabet, length=16):
    while True:
        word = randomstring(alphabet, length)
        if not has_double_letter(word):
            return word


def pwgen(alphabet, easy, length=16):
    for _ in range(terminal_height - 3):
        for _ in range(terminal_width // (length + 1)):
            if easy:
                print(easy_to_type_randomstring(alphabet, length), end=' ')
            else:
                print(randomstring(alphabet, length), end=' ')
        print()


def main():
    parser = ArgumentParser(description='Generate random passwords')
    parser.add_argument('-a', '--alphabet',
                        help='override the default alphabet')
    parser.add_argument('--complex', action='store_true', default=False,
                        help='use a very complex default alphabet', dest='complex_')
    parser.add_argument('--easy', action='store_true', default=False,
                        help='use a simple default alphabet, without ambiguous or doubled characters')
    parser.add_argument('-l', '--length', type=int, default=default_length)
    args = parser.parse_args()

    alphabet = args.alphabet
    complex_ = args.complex_
    easy = args.easy
    length = args.length

    if alphabet is None:
        if complex_:
            alphabet = alphabet_complex
        elif easy:
            alphabet = alphabet_easy
        else:
            alphabet = alphabet_default
    elif len(alphabet) < length:
        length = len(alphabet)

    pwgen(alphabet, easy, length)


if __name__ == '__main__':
    main()
