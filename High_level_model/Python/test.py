def i2b(num, bit_length=1):
  num_bin = bin(num)[2:]
  while len(num_bin)<bit_length:
    num_bin = "0"+num_bin
  return num_bin

def mp2(A,B,N,bits):  ## bit monpro
  u = 0
  N_bin = i2b(N)
  A_bin = i2b(A)
  B_bin = i2b(B,len(N_bin))[::-1] # LSB first
  for i in range(len(B_bin)):
    if B_bin[i] == '1':
      u+=A
    if u%2 != 0:
      u+=N
    u /=2
  return int(u)
  # return int(u)


def mrl(e,M,n,bits):
  h = 2**(2*bits) % n
  S = mp2(h,M,n,bits)
  C = mp2(1,h,n,bits)
  e_bin = i2b(e,bits)[::1]
  for i in range(bits):
    C, S = mp2(C,S,n,bits) if e_bin[i] == '1' else C, mp2(S,S,n,bits)

  C = mp2(1,C,n,bits)
  return C
  # print(mp2(1,r**2,n,bits*2))



e = 7
M = 10
n = 13
bits = 4

M = 50
n,e,d = 753494879,155955757, 407237893
bits = 32

                         #60082993
cipher = mrl(e,M,n,bits) #615541789
deciphered = mrl(d,cipher,n,bits)
print(cipher,deciphered)
# print(mp2(3,3,13,4))