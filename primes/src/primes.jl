## Mutable of not?
struct Primes{T <: Integer}
  _v::Vector{T}

  function Primes{T}(n::T) where {T <: Integer}
    @assert n > 0 "Expecting n (number of primes) to be > 0"

    n == one(T) && return new(T[])
    
    new(gen_primes(n))
  end

  function Primes{T}(vp::Vector{T}, n::T) where {T <: Integer}
    @assert n > length(vp) "Expecting n (number of primes) to be > $(length(vp))"

    new(gen_primes(vp, n))
  end
end

function nth(pr::Primes{T}, n::T) where {T <: Integer}
  """
  n here is the index of the n-th primes in pr list
  """
  @assert n > zero(T) "Expecting argument ot be strictly positive"

  n > length(pr._v) &&
    throw(ArgumentError("current number of primes is $(length(pr._v)) which is less than $(n)"))

  pr._v[n]
end

get_primes(pr::Primes{T}) where {T <: Integer} = pr._v

## Iterator
Base.collect(pr::Primes{T}) where {T <: Integer} = pr._v

function Base.iterate(iter::Primes{T}, state=(iter._v[1], 1)) where {T <: Integer}
  prime, ix = state

  prime === nothing && return nothing     ## are we done?
  ix == length(iter._v) &&
    return (iter._v[end], (nothing, ix))  ## is it the last prime?

  ix += 1                                 ## next prime
  (prime, (iter._v[ix], ix))
end

Base.length(iter::Primes{T}) where T = length(iter._v)
Base.eltype(::Primes{T}) where T = T

## what about a generator?

##
## Internal
##

function alloc_bvec(n::T; start=T(3))::Vector{Bool} where {T <: Integer}
  f = (n - start) / 2.
  n_elem = n % 2 == 1 ? floor(T, f) + one(T) : ceil(T, f)

  ## Allocate boolean indicator vector (sieve)
  return fill(true, n_elem)
end

function gen_primes(n::T) where {T <: Integer}
  prime_ind = alloc_bvec(n)

  x, m = 1, length(prime_ind)
  while x < m
    cp = 2x + 1
    cp * cp > 2m + 1 && break  ## DONE: because cp² > 2m + 1

    for jx in (x + cp):cp:m
      prime_ind[jx] = false
    end

    ## next prime factor to consider - we need to move past non prime integer
    x += 1
    while x < m && !prime_ind[x]
      x += 1
    end
  end

  ## Allocate and populate the actual primes vector
  primes = Vector{T}(undef, sum(prime_ind) + 1)
  primes[1] = T(2)
  ix = 2
  for x ∈ 1:m
    if prime_ind[x]
      primes[ix] = 2x + 1
      ix += 1
    end
  end
  return primes
end

function gen_primes(vp::Vector{T}, n::T) where {T <: Integer}
  last_prime = vp[end]                ## starting from last calculted prime

  prime_ind = alloc_bvec(n; start=last_prime + T(2))
  ## prime_ind holds for last_prime + 2, last_prime + 4 ...

  m = length(prime_ind)

  ## now try multiples for primes to determine which integer
  ## are prime in prime_ind
  for p in vp[2:end]
    p * p > last_prime + 2m && break  ## we are done...

    ix, cp = 1, last_prime + 2        ## ix ≡ index for primes_ind
    while ix ≤ m && cp % p != 0
      ix += 1
      cp += 2
    end
    ix > m && break                   ## we are done...

    for jx ∈ ix:p:m                   ## now eliminate multiples of p
      prime_ind[jx] = false
    end
  end

  ## finally combine
  primes = Vector{T}(undef, length(vp) + sum(prime_ind))
  copyto!(primes, vp)

  ix = length(vp) + 1
  for x ∈ 1:m
    if prime_ind[x]
      primes[ix] = last_prime + 2x
      ix += 1
    end
  end

  return primes
end
