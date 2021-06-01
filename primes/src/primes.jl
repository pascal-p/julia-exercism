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

  function Primes{T}(pr::Primes{T}, n::T) where {T <: Integer}
    @assert n < length(pr._v) "Expecting n (number of primes) to be < $(length(pr._v)), got: $(n)"

    new(pr._v[1:n]) # for re-sizing
  end
end


## external constructors
Primes{T1}(n::T2) where {T1 <: Unsigned, T2 <: Signed} = Primes{T1}(T1(n))

function Primes(n::T) where {T <: Signed}
  # @assert n > 0
  Primes{T}(n)
end

Primes(n::T) where {T <: Unsigned} = Primes{T}(n)

## accessors
v(pr::Primes) = pr._v

"""
  first_nth_primes(pr, n)

  returns first n consecutive primes if defined
  otherwise throw AssertionError
"""
function first_nth_primes(pr::Primes, n::T; from=one(T)) where {T <: Integer}
  @assert zero(T) < n - from + 1 ≤ length(pr) "Expecting argument `n` to be in range 1..$(length(pr))"
  @assert one(T) ≤ from ≤ length(pr) "Expecting argument `from` to be in range 1..$(length(pr))"
  pr._v[from:n]
end

function first_nth_primes(pr::Primes, n::T; from=one(T)) where {T <: Unsigned}
  @assert one(T) ≤ from ≤ length(pr) "Expecting argument `from` to be in range 1..$(length(pr))"
  pr._v[from:n]
end

"""
  nth(primes, n)

  given a primes list, return the n-th prime of this list if defined
  otherwise raise an exception

```jldoctest
julia> primes_lt100 = Primes{Int}(100);
julia> nth(primes_lt100, 1)
2

julia> nth(primes_lt100, 10)
29

julia> nth(primes_lt100, 100)
ERROR: ArgumentError: current number of primes is 25 which is less than 100
```
"""
function nth(pr::Primes{T}, n::T) where {T <: Integer}
  @assert n > zero(T) "Expecting argument to be strictly positive"

  n > length(pr._v) &&
    throw(ArgumentError("current number of primes is $(length(pr._v)) which is less than $(n)"))

  pr._v[n]
end

# allow safe conversion from signed to unsigned
nth(pr::Primes{T1}, n::T2) where {T1 <: Unsigned, T2 <: Signed} = nth(pr, T1(n))

Base.sum(pr::Primes{T}) where {T <: Integer} = sum(pr._v)


"""
  get_primes(primes)

  return the primes list as vector

```jldoctest
julia> primes_lt10 = Primes{Int}(10);
julia> get_primes(primes_lt10)
 4-element Vector{Int64}:
 2
 3
 5
 7

```
"""
get_primes(pr::Primes{T}) where {T <: Integer} = pr._v


"""
  generate_n_firstprimes(n)

  generates the first n primes

```jldoctest
julia> using Test
julia> @test generate_n_firstprimes(10_000) |> length == 10_000
```
"""
function generate_n_firstprimes(n::T)::Primes{T} where {T <: Integer}
  #
  # no idea about the 'density' of primes (any link with Riemann ζ function?)
  #

  f = max(2, round(Int, log(n) / log(10)) ÷ 2 + 1) # increasing factor
  m = f * n # m = 6 * n
  pr = Primes{T}(m)
  while true
    length(pr) == n && return pr
    length(pr) > n && return Primes{T}(pr, n)
    m = f * m                          # exp. increase... overflow danger
    m < 0 && throw(OverflowError("overflow detected..."))
    pr = Primes{T}(pr._v, m - length(pr))  # try adding
  end
end


## primality test
function isprime(p::T)::Bool where {T <: Integer}
  (p ≤ 1 || (p > 2 && p % 2 == 0)) && return false
  p ≤ 3 && return true
  n = floor(T, √(p))
  prime = true
  for cp ∈ generate_n_firstprimes(n)
    p % cp == 0 && return false    # cp ≠ p
  end
  prime
end


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
