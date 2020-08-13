"""
An Armstrong number is a number that is the sum of its own digits each raised
to the power of the number of digits.

Ex.
      9 is an Armstrong number, because 9 = 9^1 = 9
     10 is not an Armstrong number, because 10 != 1^2 + 0^2 = 1
    153 is an Armstrong number, because: 153 = 1^3 + 5^3 + 3^3 = 1 + 125 + 27 = 153
    154 is not an Armstrong number, because: 154 != 1^3 + 5^3 + 4^3 = 1 + 125 + 64 = 190

    115132219018763992565095597973971522401 is an Armstrong number, because: 1 ^ 39 + ... == ...

src: Wikipedia https://en.wikipedia.org/wiki/Narcissistic_number
"""

const POW_LIM = 40
## NOTE: 9 ^ 40 = 4389419161382147137 (!), UInt128(9)^40 = 147808829414345923316083210206383297601
##      BigInt(9) ^ 40 == 147808829414345923316083210206383297601

function isarmstrong(n::Integer)::Bool
  sn = string(n)
  x = length(sn)  # the exponent

  s = if x < POW_LIM
    map(d -> parse(UInt128, d) ^ x, collect(sn)) |> sum
  else
    map(d -> parse(BigInt, d) ^ x, collect(sn)) |> sum
  end

  return n == s
end
