#!/usr/bin/python -tt
# Copyright 2010 Google Inc.
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# Google's Python Class
# http://code.google.com/edu/languages/google-python-class/

"""Wordcount exercise
Google's Python class

The main() below is already defined and complete. It calls print_words()
and print_top() functions which you write.

1. For the --count flag, implement a print_words(filename) function that counts
how often each word appears in the text and prints:
word1 count1
word2 count2
...

Print the above list in order sorted by word (python will sort punctuation to
come before letters -- that's fine). Store all the words as lowercase,
so 'The' and 'the' count as the same word.

2. For the --topcount flag, implement a print_top(filename) which is similar
to print_words() but which prints just the top 20 most common words sorted
so the most common word is first, then the next most common, and so on.

Use str.split() (no arguments) to split on all whitespace.

Workflow: don't build the whole program at once. Get it to an intermediate
milestone and print your data structure and sys.exit(0).
When that's working, try for the next milestone.

Optional: define a helper function to avoid code duplication inside
print_words() and print_top().

"""

import sys


def helper(filename):
    dict_ = {}
    file = open(filename)
#    line = file.readline()  # or do file.readlines() (make a big list each item is a line) for line in file.readlines()
    
    #print('here')
#    while(line):
        #print('line print', line)
#        for word in line.lower().split():
            #print('here2')
#            dict_[word] = dict_.get(word, 0) + 1
#        line = file.readline()
        
        
    lines = file.readlines()    # can also do for line in file
    for line in lines:
        for word in line.lower().split():
            #print('here2')
            dict_[word] = dict_.get(word, 0) + 1        
    return dict_        

    
def print_top(filename):

    dict_ = helper(filename)
    new_list = sorted(dict_.items(), key= lambda x:x[1], reverse = True)[0: 20]
    print(new_list)
    for items in new_list:
        print("{} {}".format(*items))    
        
def print_words(filename):

    dict_ = helper(filename)
    new_list = sorted(dict_.items(), key= lambda x:x[0])
    for items in new_list:
        print("{} {}".format(*items))

# This basic command line argument parsing code is provided and
# calls the print_words() and print_top() functions which you must define.
def main():
  if len(sys.argv) != 3:
    print ('usage: ./wordcount.py {--count | --topcount} file')
    sys.exit(1)

  option = sys.argv[1]
  filename = sys.argv[2]
  if option == '--count':
    print_words(filename)
  elif option == '--topcount':
    print_top(filename)
  else:
    print ('unknown option: ' + option)
    sys.exit(1)

if __name__ == '__main__':
  main()
