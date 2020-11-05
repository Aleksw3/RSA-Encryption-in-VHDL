A = 8
B = 3

N = 13

def b(a, bits):
	a = str(bin(a))[2:]
	for i in range(bits-len(a)):
		a="0"+a
	return a

A = b(A,4)

u = 0 
print(A,B,N)
for bit in A[::-1]:
	print(bit)
	if bit=='1':
		u += B
	if u%2 != 0:
		u+=N
	u/=2
print(u)





