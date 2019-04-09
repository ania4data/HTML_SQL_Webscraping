#!/usr/bin/python -tt
# Copyright 2010 Google Inc.
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# Google's Python Class
# http://code.google.com/edu/languages/google-python-class/

# Additional basic list exercises

# D. Given a list of numbers, return a list where
# all adjacent == elements have been reduced to a single element,
# so [1, 2, 2, 3] returns [1, 2, 3]. You may create a new list or
# modify the passed in list.
def remove_adjacent(nums):
  list_new = []
  for i, num in enumerate(nums):
    if(i > 0 and num == nums[i-1]):
        continue
    list_new.append(num)   
  return list_new
  
#  for num in nums:
#    if len(result) == 0 or num != result[-1]:
#      result.append(num)
#  return result

# E. Given two lists sorted in increasing order, create and return a merged
# list of all the elements in sorted order. You may modify the passed in lists.
# Ideally, the solution should work in "linear" time, making a single
# pass of both lists.
def linear_merge(list1, list2):
  merged_list = []
  #  if(list2[0] >= list1[-1]): #not necessary
  #  merged_list = list1.extend(list2)
  #  return merged_list
  #  if(list1[0] >= list2[-1]): #not necessary
  # merged_list = list2.extend(list1)
  # return merged_list
  counter = 0
  #while(counter <= len(list1) + len(list2)):  will create issue if one is finished first,can't pop or index finished list need "Try/Except"
  while(len(list1) > 0 and len(list2)>0):
  
    #pop1 = list1.pop(0)
    #pop2 = list2.pop(0)
    if(list1[0] >= list2[0]):
      merged_list.extend([list2.pop(0)])  # do not do [pop1,pop2] since they might be repetition in side original list
    else:
      merged_list.extend([list1.pop(0)])
  merged_list.extend(list1)  # if either empty, does not affect merged list
  merged_list.extend(list2)
  return merged_list
      
  
    

# Note: the solution above is kind of cute, but unforunately list.pop(0)
# is not constant time with the standard python list implementation, so
# the above is not strictly linear time.
# An alternate approach uses pop(-1) to remove the endmost elements
# from each list, building a solution list which is backwards.
# Then use reversed() to put the result back in the correct order. That
# solution works in linear time, but is more ugly.


# Simple provided test() function used in main() to print
# what each function returns vs. what it's supposed to return.
def test(got, expected):
  if got == expected:
    prefix = ' OK '
  else:
    prefix = '  X '
  print ('%s got: %s expected: %s' % (prefix, repr(got), repr(expected)))


# Calls the above functions with interesting inputs.
def main():
  print ('remove_adjacent')
  test(remove_adjacent([1, 2, 2, 3]), [1, 2, 3])
  test(remove_adjacent([2, 2, 3, 3, 3]), [2, 3])
  test(remove_adjacent([]), [])

  print
  print ('linear_merge')
  test(linear_merge(['aa', 'xx', 'zz'], ['bb', 'cc']),
       ['aa', 'bb', 'cc', 'xx', 'zz'])
  test(linear_merge(['aa', 'xx'], ['bb', 'cc', 'zz']),
       ['aa', 'bb', 'cc', 'xx', 'zz'])
  test(linear_merge(['aa', 'aa'], ['aa', 'bb', 'bb']),
       ['aa', 'aa', 'aa', 'bb', 'bb'])


if __name__ == '__main__':
  main()
