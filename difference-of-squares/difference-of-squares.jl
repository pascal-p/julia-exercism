"""
    square_of_sum(n::Integer)

Calculate the square of the sum of the first `n` positive integers:
`(1 + 2 + ... + n)² = (n * (n + 1) ÷ 2)²`.
"""
function square_of_sum(n::Signed)
    n < 0 && throw(DomainError(n, "n must be non-negative"))
    return square_of_sum(unsigned(n))
end

function square_of_sum(n::T) where {T<:Union{Unsigned,BigInt}}
    W = widen(widen(T))
    x = W(n)
    s = iseven(x) ? (x >> 1) * (x + 1) : x * ((x + 1) >> 1)
    return s * s
end

"""
    sum_of_squares(n::Integer)

Sum the squares of the first `n` positive integers:
`1² + 2² + ... + n² = n * (n + 1) * (2n + 1) ÷ 6`.
"""
function sum_of_squares(n::Signed)
    n < 0 && throw(DomainError(n, "n must be non-negative"))
    return sum_of_squares(unsigned(n))
end

function sum_of_squares(n::T) where {T<:Union{Unsigned,BigInt}}
    W = widen(widen(T))
    x = W(n)
    half_prod = iseven(x) ? (x >> 1) * (x + 1) : x * ((x + 1) >> 1)
    return (half_prod * ((x << 1) + 1)) ÷ 3
end

"""
    difference(n::Integer)

Subtract the sum of squares from the square of the sum of the first `n` positive integers.
"""
function difference(n::Signed)
    n < 0 && throw(DomainError(n, "n must be non-negative"))
    return difference(unsigned(n))
end

function difference(n::Union{Unsigned,BigInt})
    return square_of_sum(n) - sum_of_squares(n)
end

## Helper
"""
    format_n(n::Integer; by = 3) -> String

Format integer `n` using (default) grouping of `by` digits separated by `_`.

# Examples
```jldoctest
julia> format_n(0x000000000034f08787bad496918c3e80)
"64_000_010_666_662_666_666_000_000"

julia> format_n(0x3984232cb3ad882c05658c9b8e800000)
"76_452_092_371_049_684_417_280_099_427_670_818_816"
```
"""
function format_n(n::Integer; by::Int = 3)
    str_n = string(n; base = 10)
    len_n = length(str_n)
    pad = mod(-len_n, by)
    padded = pad == 0 ? str_n : "0"^pad * str_n
    chunks = [padded[ix:(ix+by-1)] for ix = 1:by:length(padded)]
    return join(chunks, "_")[(pad+1):end]
end
