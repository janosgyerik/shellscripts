#!/usr/bin/env python

import unittest

from titlecase import get_new_path


class TestTitleCase(unittest.TestCase):
    def test_hello(self):
        self.assertEqual('Hello', get_new_path('hello'))

    def test_hello_txt(self):
        self.assertEqual('Hello.txt', get_new_path('hello.txt'))

    def test_hello_there_txt_dotted(self):
        self.assertEqual('Hello There.txt', get_new_path('hello.there.txt'))

    def test_hello_there(self):
        self.assertEqual('Hello There', get_new_path('hello there'))

    def test_hello__there(self):
        self.assertEqual('Hello There', get_new_path('hello  there'))

    def test_dot(self):
        self.assertEqual('.', get_new_path('.'))

    def test_dotdot(self):
        self.assertEqual('..', get_new_path('..'))

    def test_subdir(self):
        self.assertEqual('some/path/File.txt', get_new_path('some/path/file.txt'))

    def test_subdir_nobasename(self):
        self.assertEqual('some/path/.txt', get_new_path('some/path/.txt'))

    def test_subdir_dotdot(self):
        self.assertEqual('../path/File.txt', get_new_path('../path/file.txt'))

    def test_subdir_dotdot_in_middle(self):
        self.assertEqual('some/../path/File.txt', get_new_path('some/../path/file.txt'))


if __name__ == '__main__':
    unittest.main()
