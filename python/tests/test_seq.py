#!/usr/bin/env python

import unittest

from seq import seq


class TestSeq(unittest.TestCase):
    def str(self, arr):
        return [str(x) for x in arr]

    def test_3(self):
        self.assertEqual(self.str([1, 2, 3]), list(seq(3)))

    def test_3_to_10(self):
        self.assertEqual(self.str([3, 4, 5, 6, 7, 8, 9, 10]), list(seq(10, first=3)))

    def test_3_to_10_by_2(self):
        self.assertEqual(self.str([3, 5, 7, 9]), list(seq(10, first=3, incr=2)))

    def test_equalize_widths(self):
        self.assertEqual(['09', '10'], list(seq(10, first=9, equalize_widths=True)))


if __name__ == '__main__':
    unittest.main()
