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

const POW_LIM = 20
# NOTE: 9 ^ 20 == -6289078614652622815 (!), BigInt(9) ^ 20 == 12157665459056928801

function isarmstrong(n::Union{Int, Int128, BigInt})::Bool
  sn = string(n)
  x = length(sn)  # the exponent

  s = map(collect(sn)) do d
    i = parse(Int, d)
    x > POW_LIM ? BigInt(i) ^ x : i ^ x
  end |> sum

  ## OK for Int128, but not beyond..
  # s = map(d -> parse(Int, d) ^ x, collect(sn)) |> sum

  return n == s
end
