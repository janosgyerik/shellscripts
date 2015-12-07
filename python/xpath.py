#!/usr/bin/env python

import argparse
import libxml2

example = '''Example file:

    <nodes>
       <node at1="1" at2="2"> 12 </node>
       <node at1="1" at2="2" at3="3"> 123 </node>
       <node at1="1"> 1 </node>
    </nodes>

Example xpath: //node[@at1 and count(@*) = 1]
'''

parser = argparse.ArgumentParser(description='Test on an XML file an XPATH expression')
parser.add_argument('file', help='path to an xml file')
parser.add_argument('path', help='an xpath expression')
parser.add_argument('--example', help='print an example', action='store_true')

args = parser.parse_args()

if args.example:
    print(example)
    parser.exit()

xmlfile = args.file
path = args.path

doc = libxml2.parseFile(xmlfile)
ctx = doc.xpathNewContext()
print('# path:', path)
for match in ctx.xpathEval(path):
    print(match)
