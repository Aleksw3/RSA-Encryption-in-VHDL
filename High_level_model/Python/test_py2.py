def int_to_bin(in_num:int, k:int):
  in_num = str(bin(in_num))[2:]
  while len(in_num)<k:
    in_num="0"+in_num
  return in_num
def b(a, bits):
  a = str(bin(a))[2:]
  for i in range(bits-len(a)):
    a="0"+a
  return a

def mp2(A,B,N,bits):  ## bit monpro
  u = 0 
  # print(bin(A))
  A = b(A,bits)[::-1]
  # print(A)
  for bit in A:
    # print(bit)
    if bit=='1':
      u += B
    if u%2 != 0:
      u+=N
    u = (u>>1)
  # print(hex(u))
  return u

def R_L_bin_exp(M, e, n): 
  '''
  Right-left binary exponentiation method for montgomery
  '''
  global k
  print(type(e))
  print(hex(M),hex(e),hex(n))
  e_bin_str = int_to_bin(e,k)[::-1]
  print(e_bin_str)
  r = 2**k
  # C = mp2(1, (r*r)%n, n)
  C = mp2(1,(r*r)%n, n,k)
  S = mp2(M,(r*r)%n, n,k)
  print 'R2N = {0})}'.format(hex(((r%n)*(r%n))%n))
  # print(f"C = {hex(C)}")
  # print(f"S = {hex(S)}")
  # print(e_bin_str)
  # print(f"C{0} = {hex(C)[2:]} S{0} = {hex(S)[2:]}")
  for i in range(len(e_bin_str)):
    C,S = mp2(C,S,n,k) if int(e_bin_str[i]) == 1 else C,mp2(S,S,n,k)
    # print(f" e = {e_bin_str[i]} C{i} = {hex(C)[2:]} S{i} = {hex(S)[2:]}")
  # print(hex(C))
  beh = C
  C = mp2(1,C,n,k)
  # print(beh==C)
  # print(hex(C))

  return C 




n_key, e_key, d_key = 753494879,155955757, 407237893
M = 50
k = 32
Cipher = R_L_bin_exp(M, e_key, n_key)
Deciphered = R_L_bin_exp(Cipher, d_key, n_key)
print(hex(Cipher),hex(Deciphered))