import math
from generate_keys import generate_keys, multiplicative_inverse
import csv
import time

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


# def b(a, bits):
#   a = str(bin(a))[2:]
#   for i in range(bits-len(a)):
#     a="0"+a
#   print(f"LEN_A={len(a)}")
#   return a

def mp2(A,B,N,bits):  ## bit monpro
  u = 0 
  # print(bin(A))
  A = int_to_bin(A,bits+1)[::-1]
  # print(bits)
  # print(f"mp2 A - {len(A)}")
  # print(A)
  for i in range(bits+1): ## LSB - MSB
    print(f"{i} - u: {hex(u)} -- bit_{i}: {A[i]} isODD = {(u+int(A[i])*B)%2}")
    if A[i]=='1':
      u += B
    if u%2 != 0:
      u+=N
    u = (u>>1)
    # u /= 2
    # u = int(u)
  # print(hex(u))
  # print(f"mp2 end len = {len(str(bin(u)[2:]))}")
  # if len(str(bin(u)[2:])) >256:
  #   print(f"Large -> {bin(u)[2:]}")
  # elif u > (2**bits)-1:
  #   print(f"Da fuck, U>N?? {bin(u)[2:]}")
  return u


# def rl2(M, e, n): 
#   '''
#   Right-left binary exponentiation method for montgomery
#   '''
#   global k
#   e_bin_str = int_to_bin(e,k)[::-1]
#   r = 2**k
#   C = mp2(1, (r*r)%n, n,k)
#   S = mp2(M, (r*r)%n, n,k)

#   for i in range(len(e_bin_str)):
#     print(f"C = {hex(C)} S = {hex(s)}")
#     C,S = mp2(C,S,n,k) if int(e_bin_str[i]) == 1 else C, mp2(S,S,n,k)
#   C = mp2(C,1,n,k)

#   return C 


def monpro(a, b, n): # Calculates abr^(-1) mod n

  global n_, r
  t = a * b
  m = (t*n_) % r       
  u = (t + m * n) // r #r shifts the value of a*b to the right

  while u >= n:      # Calculates the modulus of abr^(-1)
    u -= n
  return u  

####### New stuff
def R_L_bin_exp(M, e, n): 
  '''
  Right-left binary exponentiation method for montgomery
  '''
  global k, R2N
  # print(type(e))
  print(f"M = {hex(M)},key = {hex(e)}, n = {hex(n)}, R2N = {hex(R2N)}")
  e_bin_str = int_to_bin(e,k)[::-1]
  # print(e_bin_str)
  r = 2**k
  C = mp2(1, R2N, n,k)
  S = mp2(M, R2N, n,k)
  # Cc = C
  # Ss = S
  # print(f"R2N = {hex(((r%n)*(r%n))%n)}")
  print(f"C = {hex(C)} S = {hex(S)} R2N = {hex(R2N)}")
  # # print(e_bin_str)
  # print(f"C{0} = {hex(C)[2:]} S{0} = {hex(S)[2:]}")
  # print(e_bin_str)
  for i in range(k): ## LSB - MSB
    # print(e_bin_str[i])
    if int(e_bin_str[i]) == 1:
      # print("C")
      C = mp2(C,S,n,k)
    # print("S")
    S = mp2(S,S,n,k)
    # print(f"{len(bin(S)[2:])}, {len(bin(C)[2:])}")
    print(f" e = {e_bin_str[i]} C{i} = {hex(C)[2:]} S{i} = {hex(S)[2:]}")
  C = mp2(1,C,n,k)

  # print(hex(C))

  return C 



if __name__ == "__main__":
  # with open("test_data.txt",'w+',newline='') as f:
  #   wr = csv.writer(f,delimiter=' ')
  #   # wr.writerow(["Id","e_key","d_key","n_key","messsage","cipher","r^2"])

  #   for i in range(50):

  #       n_key, e_key, d_key = generate_keys()
       
  #       M = 50
  #       k = 32
  #       r = 2**32
  #       assert k<=32, "k too large"
  #       Cipher = R_L_bin_exp(M, e_key, n_key)
  #       Deciphered = R_L_bin_exp(Cipher, d_key, n_key)
  #       assert Deciphered==M, "Message not alike"
  #       print(int_to_bin((r*r)%n_key,32))
  #       wr.writerow([i,int_to_bin(e_key,32),int_to_bin(d_key,32),int_to_bin(n_key,32),int_to_bin((r*r)%n_key,32),int_to_bin(M,32),int_to_bin(Cipher,32)])
       


  # n_key, e_key, d_key = generate_keys()
  # # print(n_key,e_key,d_key)
  n_key = 0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d
  e_key = 0x0000000000000000000000000000000000000000000000000000000000010001
  d_key = 0x0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9
  M =     0x0A23232323232323232323232323232323232323232323232323232323232323
  # R2N =   0x666dae8c529a9798eac7a157ff32d7edfd77038f56436722b36f298907008973
  # # M = 51
  # k = 256
  # r = 2**k
  # k = math.ceil(math.log(e_key,2))
  # assert k<=32, "k too large"
  # n_key, e_key, d_key = 753494879,155955757, 407237893
  



  # k = 257

  # # # n_key, e_key, d_key = generate_keys()
  # bits = len(bin(n_key)[2:])
  # if bits > k-1:
  #   print(f"fucking hell {bits}")
  #   # n_key, e_key, d_key = generate_keys()
  #   bits = len(bin(n_key)[2:])

  # # M = 50
  # r = 2**(k)
  # R2N = ((r**2) % n_key)
  # print(hex(R2N))
  # k=256
  
  # # print(hex(n_key),hex(e_key),hex(d_key))
  # Cipher = R_L_bin_exp(M, e_key, n_key)
  # Deciphered = R_L_bin_exp(Cipher, d_key, n_key)
  # print(hex(Cipher),Deciphered==M, "Hello")
  # print(f"Cipher should be = 85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01, \n{hex(Cipher)[2:]}\nis this true? = {0x85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01  == Cipher}")



  test = 0xa120f811c2b281fd06cf77211fbb33c2800467bb843a6022e3c43e0932b7ae7c
  # test2 =0x316e68fd23894c07e09f55f111190d6a44d7d924735d85f6bfb5b14ccfa54607
  print(hex(mp2(test,test,n_key,256)))

  # test = 0x9adaf4c8e34bd2a60a5afd5b89c2ca268d42deebaebba37157d924e3b0d95ec0
  # print(hex(mp2(test,test,n_key,k)))
  # mp2(527492901,6972855,753494879) 
  # n_key, e_key, d_key = 753494879,155955757, 407237893
       
  # M = 150
  # k = math.ceil(math.log(e_key,2))
  # k = 32
  # r = 2**k
  # Cipher = R_L_bin_exp(M, e_key, n_key)
  # print(hex(Cipher))
  # Deciphered = R_L_bin_exp(Cipher, d_key, n_key)
  # print(Cipher,Deciphered)
  # assert Deciphered == M, "They aint alike, fuck"

  # n_key = 753494879
  # r  = 33
  # r_ = multiplicative_inverse(r,n_key)
  # n_ = (r*r_ - 1) // n_key
  # print(hex(mp2(int("1f70e725",16),int("23773d",16),n_key,32))[2:])
  # print(hex(monpro(int("1f70e725",16),int("23773d",16),n_key))[2:])
  # print(hex(mp2(int("23773d",16),int("23773d",16),n_key,32))[2:])
  # print(hex(monpro(int("23773d",16),int("23773d",16),n_key))[2:])
  # print(mp2(3,3,13,4))

  # Cipher =  rl2(M,e_key,n_key)
  # Deciphered = rl2(Cipher,e_key,n_key)
  # print(Cipher, Deciphered)





# rl2(M: int, e:int, n:int):
  m = 10
  n = 13
  e = 7
  k = 5


  # print(monpro(3, 3,  13))

  # print(rl2(m,e,n))




  # n, e_key, d_key = generate_keys()

  # M = 50
  # k = math.ceil(math.log(e_key,2))

  # r = 2**k

  # r_ = multiplicative_inverse(r,n)
  # n_ = (r*r_ - 1) // n



  # assert M<n, "Message too long"

  # C = R_L_bin_exp(M, e_key, n)
  # print(f"Cipher = {C}")
  # dC = R_L_bin_exp(C, d_key, n)
  # print(f"Deciphered {dC}")
  # if dC == M:
  #   print(f"Success")
  # else:
  #   print(f"Error")

    