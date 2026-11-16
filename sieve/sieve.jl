function sieve(limit::Signed)
    limit < 0 && return typeof(unsigned(limit))[] # or throw(DomainError(...))
    return sieve(unsigned(limit))
end

function sieve(limit::T)::Vector{T} where {T<:Unsigned}
    limit <= 1 && (return T[])
    limit == 2 && (return T[2])

    cprimes = trues(limit)
    cprimes[1] = false   ## exclude 1

    # deal with multiple of 2 once
    cprimes[4:2:limit] .= false  # => simplify: step_by = cand % 2 == 1 ? 2cand : cand;  cprimes[cand*cand:step_by:limit] .= false

    for cand ∈ 2:isqrt(limit)
        !cprimes[cand] && continue
        cprimes[cand*cand:2*cand:limit] .= false
    end

    ## how many primes
    num_cand = sum(cprimes)
    primes = Vector{T}(undef, num_cand) # Vector{T}(undef, num_candArray{T,1}(undef, num_cand)
    primes[1], kx  = 2, 2

    for ix ∈ T(3):T(2):limit
        cprimes[ix] && (primes[kx] = ix; kx += 1)
    end

    primes
end
