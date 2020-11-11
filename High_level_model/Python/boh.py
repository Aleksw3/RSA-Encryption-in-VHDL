from generate_keys import generate_keys, multiplicative_inverse

def int_to_bin(in_num, k):
  boh = in_num
  in_num = str(bin(in_num))[2:]
  while len(in_num)<k:
    # print("yes")
    in_num='0'+in_num
  if len(in_num)!= k:
    print(f"LENA = {len(in_num)}")
    print(in_num,k,hex(boh))
  return in_num


def mp2(A,B,N,bits):  ## bit monpro
	u = 0 
	A = int_to_bin(A,bits+1)[::-1]
	for i in range(bits+1): ## LSB - MSB
		if A[i]=='1':
			u += B
		if u%2 != 0:
			u+=N
		u = (u>>1)

	# if u%2 != 0:
	# 	print("Yes")
	# 	u+=N
	# u = (u>>1)
	return u

def R_L_bin_exp(M, e, n): 
  '''
  Right-left binary exponentiation method for montgomery
  '''
  global k, R2N
  print(f"M = {hex(M)}\nkey = {hex(e)}\nn = {hex(n)}\nR2N = {hex(R2N)}")
  e_bin_str = int_to_bin(e,k)[::-1]
  r = 2**k
  C = mp2(1, R2N, n,k)
  S = mp2(M, R2N, n,k)
  print(f"C = {hex(C)} and S = {hex(S)}")
  for i in range(k): ## LSB - MSB
    if int(e_bin_str[i]) == 1:
      C = mp2(C,S,n,k)
    S = mp2(S,S,n,k)
    print(f"C = {hex(C)} and S = {hex(S)}")
  C = mp2(1,C,n,k)
  return C 



#### VIvado example keys
n_key = 0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d
e_key = 0x0000000000000000000000000000000000000000000000000000000000010001
d_key = 0x0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9
M =     0x0A23232323232323232323232323232323232323232323232323232323232323
k = 256

# n_key, e_key, d_key = 753494879,155955757, 407237893

### online 256 bit keys
# n_key = 0x00C8F7CF87FAD769E0C3CCB7C3FAD9B669B174FFCA06B20DE26005FDC5DFC09197
# d_key = 0x0004B501305F28B27B283AE046FFD61F9699879742A93346E0C4FC193A3983B831 
# e_key = 0x010001

## generate 32 bit values
# WORKS WITH HARDWARE MONPRO
# n_key, e_key, d_key = generate_keys()
# test_str = bin(n_key)[2:]
# while len(test_str)<28 or len(test_str)>32:
# 	n_key, e_key, d_key = generate_keys()
# 	print(len(test_str))
# 	test_str = bin(n_key)[2:]

# 56-bit values
## WORKING WITH HARDWARE MONPRO
# n_key = 0x8b7ff81815c189
# e_key = 0x10001
# d_key = 0x737f87612e5311


# 128-bit values
## WORKING WITH HARDWARE MONPRO
# n_key = 0x9ecb38646c238869a36b9e53d76e41ab
# e_key = 0x10001
# d_key = 0x33f4055545d43252e9ab0a61a4f8e4b1


# 256-bit values
## NOT WORKING WITH HARDWARE MONPRO
# n_key = 0x7f1b110b069fe13495613a8bd0279c9e0eedfb2e5f1e2c2d5216fb590e4988c7
# e_key = 0x10001
# d_key = 0xb83b73289821853bc2897b62cc039e6d1e1f02c7f4b5f64cba5128d5d60f481


# print(len(test_str))
# M = 50

k = 256
r = 2**(k+1)
R2N = ((r**2) % n_key)



Cipher = R_L_bin_exp(M, e_key, n_key)
Deciphered = R_L_bin_exp(Cipher, d_key, n_key)
print(f"cipher = {hex(Cipher)}",Deciphered==M, "Hello")
# print(f"Cipher should be = 85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01, \n{hex(Cipher)[2:]}\nis this true? = {0x85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01  == Cipher}")