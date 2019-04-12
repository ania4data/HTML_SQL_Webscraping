import numpy as np


def main():
    flag = True
    while(flag):
        letter = input('Give a letter:')
        if(letter.lower() in ['a', 'e', 'i', 'o', 'u']):
            print(letter)
            flag = False
            print('Thanks')
            break
        else:
            print('Try another time')
            
   
if __name__ == '__main__':
    main()