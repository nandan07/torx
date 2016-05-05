#!/bin/python
# ------------------------------------------------------------------
# [Author] Title   : Prasanth P.
#      Description : POSTs the torrent file and prints the key value
#      dependancies: requests, bs4
# ------------------------------------------------------------------

import os, sys
import ipdb

# dependancies: requests, bs4
import requests
from bs4 import BeautifulSoup as bs

if len(sys.argv) != 3:
    print("Usage: ./" + sys.argv[0] + " <url> <torrent file>")
    exit(1)

url = sys.argv[1]
torrent_file = sys.argv[2]
if not os.path.isfile(torrent_file):
    print("File doesn't exist.")
    exit(1)

files = {"uploadedfile": open(torrent_file, "rb")}

response = requests.post(url, files=files)
html_tree = bs(response.content, "lxml")
key_input_field = html_tree.findAll('input', {'type': ''})[0]

key_value = key_input_field.get('value')
print(key_value)

