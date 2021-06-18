const MAX_PRIME_LIM = 1_000_000  # =>  78_498 first primes, last prime:   999_983
#                     2_000_000  # => 148_933 first primes, last prime: 1_999_993
#                     5_000_000  # => 348_513 first primes, last prime: 4_999_999

@generated function eliminate!(bvec, range)
  return :(
    local v = view(bvec, range);
    v .= false
  )
end

function prime(num::Integer; lim=MAX_PRIME_LIM)::Integer
  0 < num < lim || throw(ArgumentError("Out of bounds"))

  primes = gen_primes_lt(lim)

  num > length(primes) && throw(ArgumentError("Increase the current limit of $(lim) to get the $(num)-th prime / currently only $(length(primes)) available"))

  primes[num]
end

##
## Avoiding restarting from scratch the computation of primes
##
let primes = Int[2], lim = 0
  global function gen_primes_lt(n::Integer)
    n ≤ lim && length(primes) > 2 && return primes

    if lim == 0  ## no primes yet...
      prime_ind = fill(true, ceil(Int, (n - 3) / 2) + 1)
      x, m = 1, length(prime_ind)
      while x < m
        cp = 2x + 1
        # eliminate all multiples of cp at once (using view and // assign.)
        eliminate!(prime_ind, (x + cp):cp:m)
        x = next_prime(x, m, prime_ind)
      end
      primes = vcat([2,],
                    [2x + 1 for x ∈ 1:m if prime_ind[x]])
      lim = n
      return primes

    else          ## extension of primes vector
      last_prime = primes[end]  ## starting from last calculated prime
      prime_ind = fill(true, (n - last_prime) ÷ 2)
      m = length(prime_ind)

      ## now eliminate all multiples of the known primes (primes vector)
      ## from prime_ind (≡ prime candidates)
      for p in primes[2:end]                  ## p ∈ 3, 5, 7, 11, 13,
        p * p > last_prime + 2m && break      ## we are done...
        ix, cp = next_prime(last_prime, m, p) ## find next prime cp
        ix > m && break                       ## we are done...
        eliminate!(prime_ind, ix:p:m)
      end
      ## finally combine
      primes = vcat(primes,
                    [last_prime + 2x for x ∈ 1:m if prime_ind[x]])
      lim = n
      return primes
    end
  end

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

# @inline function eliminate!(cprimes::Vector{Bool}, range)
#   v = view(cprimes, range)
#   v .= false
# end
