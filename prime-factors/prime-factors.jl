const FIRST_PRIMES = [2, 3, 5, 7, 11, 13, 17, 19]


## entry point => dispatch
function prime_factors(n::Integer; algo=pf_trial)
  n ≤ 0 && throw(DomainError("N should be positive"))
  isone(n) && return []
  n ∈ FIRST_PRIMES && return [n]

  algo(n)
end

## Trial division
function pf_trial(n::Integer)::Vector{Integer}
  divisors::Vector{UInt128} = [1, ]

  function try_div(d::Unsigned)
    while true
      q, r = divrem(n, d)

      !iszero(r) && break

      push!(divisors, d)
      n = q

      isone(n) && break
    end
  end

  d = Unsigned(isodd(n) ? 3 : 2)
  if d == 2
    try_div(d)
    d += 1
  end

  while d * d ≤ n # d ≤ floor(UInt128, AbstractFloat(√n))
    try_div(d)
    d += 2
  end

  !isone(n) && push!(divisors, n)
  return divisors[2:end]
end

## Wheel factorization
function pf_wheel(n::Integer)::Vector{Integer}
  """
  cf. https://en.wikipedia.org/wiki/Wheel_factorization

  Given a basis: (2, 3, 5,) we obtain a first turn (of divisors):
  (7, 11, 13, 17, 19, 23, 29, 31)

  a second turn is produced by adding 30 (Σ(basis)) to first turn:
  (37, 41, 43, 47, 49, 53, 59, 61)

  third turn: (67, 71, 73, 77, 79, 83, 89, 91)
  And so forth...

  One can notice the same gap between factors in each turn:
  (4, 2, 4, 2, 4, 6, 2, 6)

  last increment(inc) (6 here) is what we need for first factor of next turn
  """
  base = (2, 3, 5,)
  base_prod = reduce(*, base; init=1)
  inc  = [4, 2, 4, 2, 4, 6, 2, 6]
  lim = length(inc)

  divisors::Vector{UInt128} = [1, ]
  for q in base
    while true
      nq, r = divrem(n, q)
      r ≠ 0 && break

      push!(divisors, q)
      n = nq
    end
  end

  q, ix = 7, 1
  while q * q ≤ n
    nq, r = divrem(n, q)
    if r == 0
      push!(divisors, q)
      n = nq
    else
      q += inc[ix]
      ix = ix < lim ? ix + 1 : 1
    end
  end

  !isone(n) && push!(divisors, n)
  return divisors[2:end]
end
