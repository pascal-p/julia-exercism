const FIRST_PRIMES::NTuple = (2, 3, 5, 7, 11, 13, 17, 19)
const BASE::NTuple = (2, 3, 5)
const WHEEL_INC::NTuple = (4, 2, 4, 2, 4, 6, 2, 6)


## entry point => dispatch
"""
    prime_factors(n::T; algo = pf_wheel) where {T<:Integer}

Compute the prime factorization of a positive integer `n`, returning a
`Vector{T}` of its prime factors in non-decreasing order.

Throws a `DomainError` if `n ≤ 0`. Returns an empty `T[]` for `n == 1`.
The `algo` keyword selects the factorization strategy (`pf_wheel` by default,
or `pf_trial`).
"""
function prime_factors(n::T; algo = pf_wheel) where {T<:Integer}
    n ≤ 0 && throw(DomainError(n, "n $(n) should be a positive integer"))

    isone(n) && return T[]
    n ∈ FIRST_PRIMES && return T[n]

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

    n = try_div(n, T(2))
    d = T(3)

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

Given a basis: (2, 3, 5,) we obtain
- a 1st turn (of divisors): (7, 11, 13, 17, 19, 23, 29, 31)
- a 2nd turn is produced by adding 30 (Σ(basis)) to 1st turn:  (37, 41, 43, 47, 49, 53, 59, 61)
- a 3rd turn: (67, 71, 73, 77, 79, 83, 89, 91)
- and so forth...

One can notice the same gap between factors in each turn: (4, 2, 4, 2, 4, 6, 2, 6)
Last increment(WHEEL_INC) (i.e. 6) is what we need for first factor of next turn
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
            ix = mod1(ix + 1, lim)  # mod1(x, m) returns values in 1:m
        end
    end

    !isone(n) && push!(divisors, n)
    divisors
end
