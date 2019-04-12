import numpy as np
import sys


def main():

    n = int(sys.argv[1][3:])  # format --n1000
    print(n)
    prime_list = []
    
    for i in np.arange(1, n+1):
        counter = 0
        for j in np.arange(1, i+1):
            if(i%j == 0):
                counter += 1
            if(counter > 2):
                break # gets out of inner loop and if
        if(counter == 2 or counter == 1):
            prime_list.append(i)
    print(prime_list)
            

if __name__ == '__main__':
  main()

