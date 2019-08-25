
import math

class get_slope_dist_line():
	'''
	coordinates as a pair of tuples and 
	return the slope and distance of the line
	'''
	def __init__(self, tup_a, tup_b):
		point1 = tup_a
		point2 = tup_b
		self.delx = point1[0] - point2[0]
		self.dely = point1[1] - point2[1]

	def distance(self):
		return math.sqrt(self.delx**2 + self.dely**2)

	def slope(self):
		return self.dely/self.delx


if __name__ == '__main__':
	coordinate1 = (3,2)
	coordinate2 = (8,10)

	li = get_slope_dist_line(coordinate1,coordinate2)
	print(li.distance(), '9.433981132056603')
	print(li.slope(), '1.6')