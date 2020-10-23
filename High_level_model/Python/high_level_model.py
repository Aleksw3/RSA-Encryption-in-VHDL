import math
from generate_keys import generate_keys, multiplicative_inverse


def int_to_bin(in_num:int, k:int):
  in_num = str(bin(in_num))[2:]
  while len(in_num)<k:
    in_num="0"+in_num
  return in_num


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
  print(e_bin_str)
  r = 2**k
  C = monpro(1, (r*r)%n, n)
  S = monpro(M, (r*r)%n, n)

  for i in range(len(e_bin_str)):
    print(e_bin_str[i])
    C,S = monpro(C,S,n) if int(e_bin_str[i]) == 1 else C,monpro(S,S,n)
  C = monpro(C,1,n)

  return C 



if __name__ == "__main__":
  ## generate key s= n, e_key, d_key
  n, e_key, d_key = generate_keys()

  M = 50
  k = math.ceil(math.log(e_key,2))

  r = 2**k

  r_ = multiplicative_inverse(r,n)
  n_ = (r*r_ - 1) // n



  assert M<n, "Message too long"

  C = R_L_bin_exp(M, e_key, n)
  print(f"Cipher = {C}")
  dC = R_L_bin_exp(C, d_key, n)
  print(f"Deciphered {dC}")
  if dC == M:
    print(f"Success")
  else:
    print(f"Error")

    