import math
from generate_keys import generate_keys, multiplicative_inverse
import csv


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
  A = b(A,bits)[::-1]
  for bit in A:
    print(bit)
    if bit=='1':
      u += B
    if u%2 != 0:
      u+=N
    u/=2
  return int(u)


def rl2(M: int, e:int, n:int): 
  '''
  Right-left binary exponentiation method for montgomery
  '''
  global k
  e_bin_str = int_to_bin(e,k)[::-1]
  r = 2**k
  C = mp2(1, (r*r)%n, n,k)
  S = mp2(M, (r*r)%n, n,k)

  for i in range(len(e_bin_str)):
    C,S = mp2(C,S,n,k) if int(e_bin_str[i]) == 1 else C,mp2(S,S,n,k)
  C = mp2(C,1,n,16)

  return C 


def monpro(a:int, b:int, n:int): # Calculates abr^(-1) mod n
  global n_, r
  t = a * b
  m = (t*n_) % r       
  u = (t + m * n) // r #r shifts the value of a*b to the right

  while u >= n:      # Calculates the modulus of abr^(-1)
    u -= n
  return u  

####### New stuff
def R_L_bin_exp(M: int, e:int, n:int): 
  '''
  Right-left binary exponentiation method for montgomery
  '''
  global k
  e_bin_str = int_to_bin(e,k)[::-1]
  r = 2**k
  C = monpro(1, (r*r)%n, n)
  S = monpro(M, (r*r)%n, n)
  # print(f"C = {int_to_bin(C,32)}")
  # print(f"S = {int_to_bin(S,32)}")
  # print(e_bin_str)
  print(f"C{0} = {hex(C)[2:]} S{0} = {hex(S)[2:]}")
  for i in range(len(e_bin_str)):
    C,S = monpro(C,S,n) if int(e_bin_str[i]) == 1 else C,monpro(S,S,n)
    print(f" e = {e_bin_str[i]} C{i} = {hex(C)[2:]} S{i} = {hex(S)[2:]}")
  C = monpro(C,1,n)

  return C 



if __name__ == "__main__":
  # generate key s= n, e_key, d_key
  # with open("test_data.txt",'w+',newline='') as f:
  #   wr = csv.writer(f,delimiter=' ')
  #   # wr.writerow(["Id","e_key","d_key","n_key","messsage","cipher","r^2"])

  #   for i in range(50):

  #       n_key, e_key, d_key = generate_keys()
       
  #       M = 50
  #       k = math.ceil(math.log(e_key,2))
  #       r = 2**k
  #       assert k<=32, "k too large"
  #       r_ = multiplicative_inverse(r,n_key)
  #       n_ = (r*r_ - 1) // n_key
  #       Cipher = R_L_bin_exp(M, e_key, n_key)
  #       Deciphered = R_L_bin_exp(Cipher, d_key, n_key)
  #       assert Deciphered==M, "Message not alike"
  #       wr.writerow([i,int_to_bin(e_key,32),int_to_bin(d_key,32),int_to_bin(n_key,32),int_to_bin(M,32),int_to_bin(Cipher,32),int_to_bin(r**2,64)[0:32]])
        
  n_key, e_key, d_key = 753494879,155955757, 407237893
       
  M = 50
  k = math.ceil(math.log(e_key,2))
  k = 32
  r = 2**k
  r_ = multiplicative_inverse(r,n_key)
  n_ = (r*r_ - 1) // n_key
  Cipher = R_L_bin_exp(M, e_key, n_key)
  Deciphered = R_L_bin_exp(Cipher, d_key, n_key)
  print(Cipher,Deciphered)
  assert Deciphered == M, "They aint alike, fuck"

  # n_key = 753494879
  # r  = 33
  # r_ = multiplicative_inverse(r,n_key)
  # n_ = (r*r_ - 1) // n_key
  # print(hex(mp2(int("1f70e725",16),int("23773d",16),n_key,32))[2:])
  # print(hex(monpro(int("1f70e725",16),int("23773d",16),n_key))[2:])
  # print(hex(mp2(int("23773d",16),int("23773d",16),n_key,32))[2:])
  # print(hex(monpro(int("23773d",16),int("23773d",16),n_key))[2:])
  print(mp2(3,3,13,4))

  # Cipher =  rl2(M,e_key,n_key)
  # Deciphered = rl2(Cipher,e_key,n_key)
  print(Cipher, Deciphered)





# rl2(M: int, e:int, n:int):
  # m = 123
  # n = 3223
  # e = 17
  # k = 16


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

    