import matplotlib.pyplot as plt
import sys
X = []
Y = []
with open(str(sys.argv[1]),"r") as f:
    output = f.read()

output = output.split("\n")
for i in range(len(output) - 1):
    A = output[i].split()
    X.append(int(A[0]))
    Y.append(int(A[1]))

plt.plot(X,Y)
plt.show()