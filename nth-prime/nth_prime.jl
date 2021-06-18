module YaPrime

const _PRIMES = Int64[2, 3, 5, 7, 11, 13];

export _PRIMES, nth_prime
"""
The n-th Prime Number

The prime number theorem is equivalent to the statement that the n-th prime number pₙ satisfies
  pₙ ∼ n × ln(n)

the asymptotic notation meaning again that the relative error of this approximation approaches 0 as n → ∞.

"""
function nth_prime(num::Integer)::Integer
  num == 0 && throw(ArgumentError("Argument should be >0"))
  n = length(YaPrime._PRIMES)

  (num <= n) && return YaPrime._PRIMES[num];

  # primes = gen_primes_lt(lim)
  lim = ceil(Int, num * log(num) * 1.2) # 20% error
  gen_primes_upto!(lim)
  YaPrime._PRIMES[num]
end

##
## Avoiding restarting from scratch the computation of primes
##
function gen_primes_upto!(n::Integer)# ::Vector{Int64}
  last_prime = YaPrime._PRIMES[end]  ## starting from last calculated prime
  prime_ind = fill(true, (n - last_prime) ÷ 2)
  m = length(prime_ind)

  ## now eliminate all multiples of the known primes (primes vector)
  ## from prime_ind (≡ prime candidates)
  for p in YaPrime._PRIMES[2:end]         ## p ∈ 3, 5, 7, 11, 13,
    p * p > last_prime + 2m && break      ## we are done...
    ix, cp = next_prime(last_prime, m, p) ## find next prime cp
    ix > m && break                       ## we are done...
    (_v = view(prime_ind, ix:p:m)) .= false
  end
  ## finally combine
  push!(YaPrime._PRIMES, [last_prime + 2x for x ∈ 1:m if prime_ind[x]]...)
end

"""
find next prime, given last known prime so far
cp is a prime if it cannot be divided by any of the prime that precedes it
"""
@inline function next_prime(last_prime::Integer, m::Integer, p::Integer)::Tuple{Integer, Integer}
  ix = 1                            ## starting index for primes_ind
  cp = last_prime + 2               ## (possible) next candidate prime
  while ix ≤ m && cp % p != 0
    ix += 1
    cp += 2
  end
  (ix, cp)
end

@inline function next_prime(x::Integer, m::Integer, prime_ind::Vector{Bool})::Integer
  x += 1
  while x < m && !prime_ind[x]
    x += 1
  end
  x
end

end # module
