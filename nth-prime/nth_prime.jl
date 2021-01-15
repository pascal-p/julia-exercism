const MAX_PRIME_LIM = 1_000_000  # =>  78_498 first primes, last prime:   999_983
#                     2_000_000  # => 148_933 first primes, last prime: 1_999_993
#                     5_000_000  # => 348_513 first primes, last prime: 4_999_999

function prime(num::Integer; lim=MAX_PRIME_LIM)::Integer
  0 < num < lim || throw(ArgumentError("Out of bounds"))

  primes = gen_primes_lt(lim)

  if num > length(primes)
    throw(ArgumentError("You need to increase the current limit of $(lim) to get the $(num)-th prime / currently only $(length(primes)) available"))
  end

  primes[num]
end

##
## Avoiding restarting from scracth the computation of primes
##
let primes = Int[2], lim = 0

  global function gen_primes_lt(n::Integer)
    n ≤ lim && length(primes) > 2 && return primes

    if lim == 0   ## init of primes vector
      prime_ind = vcat([ true ],
                       [ true for _ ∈ 3:2:(n - 1) ])

      x, m = 1, length(prime_ind)
      while x < m
        cp = 2x + 1
        for jx in (x + cp):cp:m
          prime_ind[jx] = false
        end
        x += 1
        while x < m && !prime_ind[x]
          x += 1
        end
      end
      primes = vcat([2,], [2x + 1 for x ∈ 1:m if prime_ind[x]])
      lim = n
      return primes

    else          ## extension of primes vector
      last_prime = primes[end]            ## starting from last calculted prime

      prime_ind = [true for _ ∈ (last_prime + 2):2:n]
      ## prime_ind holds for last_prime + 2, last_prime + 4 ...

      m = length(prime_ind)

      ## now try multiples for primes to determine which integer
      ## are prime in prime_ind

      for p in primes[2:end]
        p * p > last_prime + 2m && break  ## we are done...

        ix = 1                            ## index for primes_ind
        cp = last_prime + 2
        while ix ≤ m && cp % p != 0
          ix += 1
          cp += 2
        end
        ix > m && break                   ## we are done...

        for jx ∈ ix:p:m                   ## now eliminate multiples of p
          prime_ind[jx] = false
        end

        ## try next prime
      end
      ## finally combine
      primes = vcat(primes,
                    [last_prime + 2x for x ∈ 1:m if prime_ind[x]])
      lim = n
      return primes
    end
  end

end

## re-starting from scracth each time
# let primes = Int[2], lim = 0
#   global function gen_primes_lt0(n::Integer)
#     """
#     Using Eratosthenes siver method
#     """
#     n ≤ lim && length(primes) > 2 && return primes
#     # we need to (re)start from scratch
#     prime_ind = vcat([ true ],
#                      [ true for _ ∈ 3:2:(n - 1) ])
#     x, m = 1, length(prime_ind)
#     while x < m
#       cp = 2x + 1
#       for jx in (x + cp):cp:m
#         prime_ind[jx] = false
#       end
#       x += 1
#       while x < m && !prime_ind[x]
#         x += 1
#       end
#     end
#     primes = vcat([2,], [2x + 1 for x ∈ 1:m if prime_ind[x]])
#     return primes
#   end
# end
