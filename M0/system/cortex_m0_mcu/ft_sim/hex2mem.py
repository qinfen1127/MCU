import os
import sys

mem = open("../../ft_sim/FT.mem",'w+')

#print('memory_initialization_radix=16',file=mem)
#print('memory_initialization_vector=',file=mem)

for line in open(sys.argv[1]) :
	if line[0] == "@":
		continue
	elif len(line) == 49:
		print(line[0:2]+line[3:5]+line[6:8]+line[9:11],file=mem)
		print(line[12:14]+line[15:17]+line[18:20]+line[21:23],file=mem)
		print(line[24:26]+line[27:29]+line[30:32]+line[33:35],file=mem)
		print(line[36:38]+line[39:41]+line[42:44]+line[45:47],file=mem)
	elif len(line) == 37:
		print(line[0:2]+line[3:5]+line[6:8]+line[9:11],file=mem)
		print(line[12:14]+line[15:17]+line[18:20]+line[21:23],file=mem)
		print(line[24:26]+line[27:29]+line[30:32]+line[33:35],file=mem)
	elif len(line) == 25:
		print(line[0:2]+line[3:5]+line[6:8]+line[9:11],file=mem)
		print(line[12:14]+line[15:17]+line[18:20]+line[21:23],file=mem)
	elif len(line) == 13:
		print(line[0:2]+line[3:5]+line[6:8]+line[9:11],file=mem)
