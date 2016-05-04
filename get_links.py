#!/usr/bin/python
import ipdb,sys

def get_link(html_file):
    data   = open(html_file).read()
    folder = data.split('<h3><b>')[1].split('</b>')[0]
    print(folder)
    data   = data.split('alert alert-success')[1].split('</center>')[0]
    data   = data.split('<a href="')[1:]
    for line in data:
        filename = line.split('">')[1].split('</a>')[0]
        link     = line.split('"')[0]
        print(filename + "|" + link)

html_file = sys.argv[1]
get_link(html_file)
#ipdb.set_trace()
