#!/bin/sh

cd $(dirname "$0")

# E121 continuation line indentation is not a multiple of four
# E123 closing bracket does not match indentation of opening bracket's line
# E126 continuation line over-indented for hanging indent
# E128 continuation line under-indented for visual indent
# E501 line too long > 79 characters
echo '### pep8'
pep8 . | grep -v \
    -e E128 \
    -e E501
echo

echo '### pyflakes'
pyflakes .
echo
