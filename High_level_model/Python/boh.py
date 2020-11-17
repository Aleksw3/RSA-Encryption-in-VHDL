from generate_keys import generate_keys, multiplicative_inverse

def int_to_bin(in_num, k):
  boh = in_num
  in_num = str(bin(in_num))[2:]
  while len(in_num)<k:
    # print("yes")
    in_num='0'+in_num
  # if len(in_num)!= k:
  #   print(f"LENA = {len(in_num)}")
  #   print(in_num,k,hex(boh))
  return in_num

def mp2_radix(A,B,N,bits,radix,modulus_inv):  ## bit monpro
  u = 0 
  A = int_to_bin(A,bits+1)[::-1]+"0" ##257 bits so easier to just a a 0 to msb
  B_bin_0 = int_to_bin(B,0)[-2:]
  # print(B_bin_0,bin(B)[2:])
  for i in range(0,bits+1,2): ## LSB - MSB for A
    A_i = int((A[i:i+2])[::-1],2)
    u+=A_i*B
    U_bin_str = int_to_bin(u,10) #[MSB-0] - [LSB-x]
    if int(U_bin_str[-2:],2) != 0:
      qj = ((A_i*(int(B_bin_0,2))+int(U_bin_str[-2:],2))*(modulus_inv))%radix
      u += qj*N
    u = (u>>2)
  return u

def mp2(A,B,N,bits):  ## bit monpro
  u = 0 
  A = int_to_bin(A,bits+1)[::-1]
  for i in range(bits+1): ## LSB - MSB
    if A[i]=='1':
      u += B
    if u%2 != 0:
      u+=N
    u = (u>>1)
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
  print(f"C1 = {hex(C)} S1 = {hex(S)}")
  for i in range(k): ## LSB - MSB
    if int(e_bin_str[i]) == 1:
      C = mp2(C,S,n,k)
    S = mp2(S,S,n,k)
    print(f"C{i+1} = {hex(C)} S{i+1} = {hex(S)}")
  C = mp2(1,C,n,k)
  return C 



#### VIvado example keys
n_key = 0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d
e_key = 0x0000000000000000000000000000000000000000000000000000000000010001
d_key = 0x0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9
M =     0x0A23232323232323232323232323232323232323232323232323232323232323
Cipher = 0x6772DD02155F2FFE66CE467C3834B7E9982128043B1BF818AC87A5FBC15F4B30
# Cipher =     0x93b172508e464b44361b7d8b23ee0b3121abdf538a9fbbfe6fb3f555dbdc55ae
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
# R2N = 



# Cipher = R_L_bin_exp(M, e_key, n_key)
# Deciphered = R_L_bin_exp(Cipher, d_key, n_key)
# print(f"Cipher - {hex(Cipher)} \nDeciphered = {hex(Deciphered)}")
# print(f"cipher = {hex(Cipher)}",Deciphered==M, "Hello")
# print(f"Cipher should be = 85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01, \n{hex(Cipher)[2:]}\nis this true? = {0x85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01  == Cipher}")

N = 0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d
X = 0xee5279c61dc177d39b873a8488544e5e4a19411713c81616103660f57922a05c
Y = 0xee5279c61dc177d39b873a8488544e5e4a19411713c81616103660f57922a05c
expected = 0x101d74e7ea7dbd9469e02bd65cf8b1c791632d0573e6246c2243d98125458a99c
bits = 256
modulus_inv = 1
radix = 4

radix_monpro_output0  = mp2_radix(X,Y,N,bits,radix,0)
radix_monpro_output1  = mp2_radix(X,Y,N,bits,radix,3)
radix_monpro_output2  = mp2_radix(X,Y,N,bits,radix,2)
radix_monpro_output3  = mp2_radix(X,Y,N,bits,radix,3)
# (A,B,N,bits
# print(f"output mp:{hex(mp2(X,Y,N,bits))}")

print(f"Output0:   {hex(radix_monpro_output0)}\nOutput1:   {hex(radix_monpro_output1)}\nOutput2:   {hex(radix_monpro_output2)}\nOutput3:   {hex(radix_monpro_output3)}\nExpected: {hex(expected)}")