
import math

class Cylinder():
	'''
	get height and radius, calculate volume
	and surface area
	'''
	pi = 4.0* math.atan(1.0)
	def __init__(self, height=1, radius=1):
		self.height = height
		self.radius = radius


	def volume(self):
		return self.pi * self.radius**2.0 * self.height

	def surface_area(self):
		return 2.0* self.pi * self.radius**2.0 + 2.0* self.pi * self.radius * self.height


if __name__ == '__main__':

	c = Cylinder(2,3)
	print(c.volume(), '56.52')
	print(c.surface_area(), '94.2')