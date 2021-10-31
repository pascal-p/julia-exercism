push!(LOAD_PATH, "../primes/src")

using YA_PRIMES
using Random

function private_key(p::Integer)::Integer
  check_factor(p)
  rand(3:p - 1)
end

function public_key(p::Integer, g::Integer, privkey::Integer)::Integer
  check_key(privkey, p)
  BigInt(g) ^ privkey % p  # avoid overflow at the cost of speed
end

function calc_secret(p::Integer, pub::Integer, priv::Integer)::Integer
  check_key(priv, p)
  check_key(pub, p)
  BigInt(pub) ^ priv % p
end

check_factor(p::Integer) = (p < 2 || !isprime(p)) && throw(ArgumentError("p must be a prime > 2"))

check_key(pkey::Integer, p::Integer) = (p % 2 == 0 || pkey > p) && throw(ArgumentError("Not a valid key"))
