const FIRST_PRIME = [2, 3, 5, 7, 11, 13, 17, 19]

##
## A data structure for the sieve of Eratosthenes
##
struct Sieve{T}
  n::T                 ## limit
  np::T                ## number of primes
  lastp::T             ## last prime in our list
  cp::Vector{T}
  flag::Vector{Bool}

  function Sieve{T}(cp::Vector{T}, flag::Vector{Bool}, n::T) where T
    @assert n > 2

    if length(flag) < length(cp)
      nflag = fill(true, length(cp)) ## make defensive copy of flag
      copyto!(nflag, flag)
    end

    eratosthenes!(cp, nflag, n)
    np = sum(nflag)

    lastp = one(T)                   ## find last prime in the list
    for ix ∈ length(nflag):-1:1
      if nflag[ix]
        lastp = cp[ix]
        break
      end
    end

    new(n, np, lastp, cp, nflag)
  end
end

function prime_list(s::Sieve{T}) where T
  jx, primes = one(T), Vector{T}(undef, s.np)
  for ix in 1:length(s.cp)
    if s.flag[ix]
      primes[jx] = s.cp[ix]
      jx += 1
    end
  end
  return primes
end

## iterator
Base.collect(s::Sieve{T}) where T = prime_list(s)

function Base.iterate(iter::Sieve{T}, state=(iter.cp[1], 1)) where T
  prime, ix = state

  prime === nothing && return nothing     ## are we done?
  prime == iter.lastp &&                  ## is it the last prime?
    return (iter.lastp, (nothing, ix))

  ix += 1                                 ## next prime
  while ix < length(iter.flag)
    iter.flag[ix] && break
    ix += 1
  end

  (prime, (iter.cp[ix], ix))
end

Base.length(iter::Sieve{T}) where T = iter.np
Base.eltype(iter::Sieve{T}) where T = T

function is_prime(s::Sieve{T}, n::T) where T
  @assert n ≤ s.n "Expected n:$(n) to be less than $(length(s.cp))"
  if n ≤ s.n
    ix = findfirst(x -> x == n, s.cp)
    return ix === nothing ? false : s.flag[ix]
  end
  false
end

## ================================================================
##
## Client portion
##
## ================================================================

"""
1 - get all primes ≤ n
  => need to generate those primes

2 - ∀ prime, check whether prime is circular by rotating its digits
  => need to generate all rotations of a given number
"""
function circular_prime(n::Integer)::Integer
  ne = max(4n, rotation(n)...)
  primes = Sieve{Int}([FIRST_PRIME..., collect(23:2:ne)...],
                      [true, true, true, true, true, true, true, true], ne)
  t_n = typeof(n)
  cnt = zero(t_n)

  for p ∈ primes
    p > n && break
    all_primes = true

    for cp ∈ rotation(p)[2:end]
      # Do not count rotation for which cp is > than the limit
      if cp > ne
        all_primes = false
        break
      end

      if !is_prime(primes, cp)
        all_primes = false
        break
      end
    end

    all_primes && (cnt += one(t_n))
  end

  return cnt
end


"""
Generate all the prime numbers ≤ n
"""
function eratosthenes!(cp::Vector{T}, flag::Vector{Bool}, n::Integer) where T
  ix_pf = 2
  pf = cp[ix_pf]               ## first odd prime factor 3 at pos. 2, this is 3

  while pf * pf ≤ n
    ix = 9                     ## starting at cp[9] ≡ 23 - first candidate prime to test

    found_multiple = false
    while ix ≤ length(cp)      ## upper limit
      if cp[ix] == pf
        # NO-OP
        #
      elseif cp[ix] % pf == 0  ## eliminate all candidate prime multiple of pf
        flag[ix] = false
        found_multiple = true

      elseif !found_multiple
        ix += 1                ## try to find a multiple
        continue
      end

      ix += pf
    end

    ix_pf += 1
    while !flag[ix_pf]
      ix_pf += 1
    end

    pf = cp[ix_pf]
  end
  #
  # @assert cp[13] == 31 && flag[13] "Expected cp[13] == 31 (got $(cp[13])) and flag[13] to be true, got: $(flag[13])"
  #
end


"""
Generate all rotations of given (prime) number p
"""
function rotation(p::Integer)::Vector{Integer}
  n, ndigits = p, floor(Int, log(p)/log(10)) + 1
  v = Vector{Integer}(undef, ndigits)
  v[1] = n

  for ix in 2:ndigits
    q, r = divrem(n, 10^(ndigits - 1))
    n = 10r + q
    v[ix] = n
  end

  return unique(v)
end
