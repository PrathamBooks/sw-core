#!/usr/bin/env python
import argparse
import csv

parser = argparse.ArgumentParser(description='Diff ht vs mt.')
parser.add_argument('csv_file', metavar='csv_file',
                    help='csv file with the two translations')

args = parser.parse_args()

ht_words = 0
mt_words = 0
ht_lines = 0
mt_lines = 0
identical_pages = 0
identical_lines = 0
npages = 0


with open(args.csv_file, 'rb') as csvfile:
    csv_file = csv.reader(csvfile, delimiter=',')
    for row in csv_file:
        ht = row[0]
        mt = row[1]
        npages += 1
        if ht == mt:
            identical_pages += 1

        ht_words += len(ht.split(' '))
        mt_words += len(mt.split(' '))
        ht_lines += len(ht.split('\n'))
        mt_lines += len(mt.split('\n'))

        for h_line in ht.split('\n'):
            for m_line in mt.split('\n'):
                if h_line == m_line:
                    identical_lines += 1

    print "Total Pages:", npages, "Identical Pages:", identical_pages, "Identical Sentences:", identical_lines
    print "Human   Word Count:", ht_words, " Sentence Count:", ht_lines
    print "Machine Word Count:", mt_words, " Sentence Count:", mt_lines
