
def myfunc1(*args):
	'''
	return sum of inputs
	'''
	return sum(args)


def myfunc2(*args):
	'''
	return a list even numbers
	'''
	return [arg for arg in args if arg % 2 == 0]


def myfunc3(args):
	'''
	return a list even numbers
	'''
	return "".join([arg if i % 2 == 0 else arg.upper() for i, arg in enumerate(args.lower())])

def myfunc4(*args, **kwargs):
	print(len(args), kwargs['code'] * 2)


def myfunc5(args):
	return args[0] * 5



if __name__ == '__main__':
	print(myfunc2(1, 5 , 12, 14))
	print(myfunc3('EKJbEsdlfwerrksek'))
	myfunc4(1, 42, 5, 'o', code='python ')
	print(list(map(myfunc5, 'test')))
	print(list(map(myfunc5, ('10', '20', '30'))))
#[12, 14]
#eKjBeSdLfWeRrKsEk
#4 python python
#['ttttt', 'eeeee', 'sssss', 'ttttt']
#['11111', '22222', '33333']