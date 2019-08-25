
class Account():
	'''
	create an account with account ower and
	initial money, capable of adding removing (conditional)
	from the account
	'''

	def __init__(self, name, amount=0):
		self.owner = name
		self.amount = amount

	def deposit(self, add_amount):
		self.amount += add_amount
		return f'Deposit Accepted'

	def withdraw(self, withdraw_amount):
		tmp = self.amount - withdraw_amount
		if tmp < 0:
			return f'Funds Unavailable'
		else:
			self.amount = tmp
			return f'Withdrawal Accepted'
	def __str__(self):
		'''
		overwrite the object memory address
		and using print comes to __str__
		'''
		return f'Account owner:   {self.owner}\nAccount balance: ${self.amount}'


	def __del__(self):
		print('Account of {} with content ${} was deleted'.format(self.owner, self.amount))

if __name__ == '__main__':

	acct = Account('Anoosheh',100)
	print(acct)
	#Account owner:   Jose
	#Account balance: $100
	print(acct.owner, 'Anoosheh')
	print(acct.amount, '100')
	print(acct.deposit(50), 'Deposit Accepted')
	print(acct.withdraw(75), 'Withdrawal Accepted')
	print(acct.withdraw(500), 'Funds Unavailable!')
	del acct