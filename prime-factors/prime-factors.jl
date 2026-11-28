const FIRST_PRIMES::NTuple = (2, 3, 5, 7, 11, 13, 17, 19)
const BASE::NTuple = (2, 3, 5)
const WHEEL_INC::NTuple = (4, 2, 4, 2, 4, 6, 2, 6)


## entry point => dispatch
function prime_factors(n::T; algo = pf_wheel) where {T<:Integer}
    n ≤ 0 && throw(DomainError(n, "n $(n) should be a positive integer"))

    isone(n) && return T[]
    n ∈ FIRST_PRIMES && return [n]

    algo(n)
end


## Trial division
function pf_trial(n::T) where {T<:Integer}
    divisors = T[]

    function try_div(n::T, d::T) where {T<:Integer}
        while true
            q, r = divrem(n, d)
            !iszero(r) && break

            push!(divisors, d)
            n = q

            isone(n) && break
        end
        n
    end

    d = isodd(n) ? T(3) : T(2)

    if d == T(2)
        n = try_div(n, d)
        d += T(1)
    end

    while d ≤ n ÷ d  # overflow-safe
        n = try_div(n, d)
        d += T(2)
    end

    !isone(n) && push!(divisors, n)
    divisors
end


## Wheel factorization
"""
cf. https://en.wikipedia.org/wiki/Wheel_factorization

Given a basis: (2, 3, 5,) we obtain a first turn (of divisors):
  (7, 11, 13, 17, 19, 23, 29, 31)

a second turn is produced by adding 30 (Σ(basis)) to first turn:
  (37, 41, 43, 47, 49, 53, 59, 61)

a third turn: (67, 71, 73, 77, 79, 83, 89, 91)
And so forth...

One can notice the same gap between factors in each turn:
(4, 2, 4, 2, 4, 6, 2, 6)

last increment(inc) (6 here) is what we need for first factor of next turn
"""
function pf_wheel(n::T) where {T<:Integer}
    lim = length(WHEEL_INC)
    divisors = T[]

    for q in BASE
        while true
            nq, r = divrem(n, q)
            r ≠ 0 && break

            push!(divisors, q)
            n = nq  # mutating n!
        end
    end

    q, ix = T(7), 1
    while q ≤ n ÷ q
        nq, r = divrem(n, q)

        if r == 0
            push!(divisors, q)
            n = nq
        else
            q += WHEEL_INC[ix]
            ix = ix < lim ? ix + 1 : 1
        end
    end

    !isone(n) && push!(divisors, n)
    divisors
end
