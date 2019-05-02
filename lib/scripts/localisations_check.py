#!/usr/bin/python3

from re import findall, M, compile
from json import load
from os import walk, path
from argparse import ArgumentParser
from sys import exit

parser = ArgumentParser(description="Program to fetch translation keys from all the files in 'directory' and compare with the keys from 'json file'")
parser.add_argument('directory', help='Directory path to search translation keys"')
parser.add_argument('fsuffix', help='File type to search keys, like "js" or "jsx"')
parser.add_argument('json', help='Full path of json file')

# Parsing arguments
args = parser.parse_args()
dir_path = args.directory
file_suffix = args.fsuffix
json_file = args.json

if not path.isdir(dir_path):
  print("'{0}': Directory not found".format(dir_path))
  exit(1)

if not path.isfile(json_file):
  print("'{0}': File not found".format(json_file))
  exit(1)

# Fetching keys from files in the directory
key_list = []
f_count = 0
print("Searching for keys in '{0}'...".format(dir_path))
key_pattern = compile('t\([\'\"](\w+\.[\w\-]*\w+[\.[\w\-]*\w+]*)[\'\"]', M)
file_pattern = compile('.*\.'+file_suffix.lstrip('.')+'$')
for root, dirs, files in walk(dir_path):
  # Filtering files with particular suffixes
  files_list = list(filter(lambda f: file_pattern.findall(f), files))
  f_count += len(files_list)
  for f in files_list:
    try:
      with open(root+'/'+f) as fd:
        key_list += key_pattern.findall(fd.read())
    except IOError:
      print("Error while reading file {0}, skipping...".format(root+'/'+f))
      continue

if (f_count == 0):
  print("No files found in '{0}' with extension '{1}'".format(dir_path, file_suffix))
  print("Program exited with errorcode: 1")
  exit(1)

if not key_list:
  print("No keys found in directory '{0}'".format(dir_path))
  print("Program exited with errorcode: 1")
  exit(1)
else:
  key_set = set(key_list)

# Fetching keys from json file
try:
  json_set = set(load(open(json_file)).keys())
except IOError:
  print("{0}: cannot read file".format(json_file))
  print("Program exited with errorcode: 1")
  exit(1)

# Comparing keys
if key_set.issubset(json_set):
  print("Translation keys check completed succesfully !!!")
  exit(0)
else:
  print("Following keys not found in '{0}'".format(json_file))
  print(key_set-json_set)
  print("Program exited with errorcode: 1")
  exit(1)
