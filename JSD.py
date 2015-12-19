import numpy as np
import sys

# Jesson-Shannon Divergence
def JSD(col, P, Q):
	PM = QM = 0
	for i in range(col):
		# compute m
		m = 0.5*(P[i] + Q[i])

		# if both P[i] and Q[i] are zero
		if (not P[i]) and (not Q[i]):
			continue
		# if P[i] is zero
		if (not P[i]):
			QM -= Q[i]
		# if Q[i] is zero
		elif (not Q[i]):
			QM -= P[i]
		else:
			PM -= P[i] * np.log2(m/P[i])
			QM -= Q[i] * np.log2(m/Q[i])
	return 0.5 * np.fabs(PM+QM)


def distance(input, output, fname):
	with open(input, 'r') as f:
		data = f.readlines()
		f.close()
		if not data:
			print "Empty data set"
			sys.exit(0)

	colsize = len(data[0].split('\t'))
	rowsize = len(data)
	dMatrix = [[0]*rowsize for x in range(rowsize)]
	for i in range(rowsize):
		dMatrix[i][i] = 0
		for j in range(i+1,rowsize):
			dis = JSD(colsize, map(float, data[i].split('\t')), 
				map(float, data[j].split('\t')))
			dMatrix[i][j] = dMatrix[j][i] = dis

	# test
	for i in range(rowsize):
		for j in range(i,rowsize):
			if not( dMatrix[i][j] == dMatrix[i][j]):
				print "not equal"

	# write to file
	fin = open(fname, 'r')
	names = fin.readlines()
	maxLen = (int)(max(len(n) for n in names))
	matrix = str(len(names))+"\n"
	for i in range(rowsize):
		# phylip format 
		matrix += names[i][0:-1]+' '*(maxLen-len(names[i])+40)
		for j in range(rowsize):
			matrix += str('%.3e' % dMatrix[i][j])+" "
		matrix += '\n'
	
	out = open(output,'w')
	out.write(matrix)
	out.close()


def main():
	input = sys.argv[1]
	output = sys.argv[2]
	fname = sys.argv[3]

 	distance(input, output, fname)


if __name__ == '__main__':
	main()

