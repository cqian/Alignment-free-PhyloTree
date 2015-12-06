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
		if (not P[i]):
			QM -= Q[i]
		elif (not Q[i]):
			QM -= P[i]
		else:
			PM -= P[i] * np.log2(m/P[i])
			QM -= Q[i] * np.log2(m/Q[i])
	return 0.5 * np.fabs(PM+QM)


def distance(input, output):
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

	# write to file
	out = open(output+'.txt','w')
	for i in range(rowsize):
		for j in range(rowsize):
			out.write(str(dMatrix[i][j])+"\t")
		out.write("\n")
	out.close()


def main():
	input = sys.argv[1]
	output = sys.argv[2]
 	distance(input, output)


if __name__ == '__main__':
	main()

