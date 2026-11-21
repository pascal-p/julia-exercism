const AVInt = AbstractVector{T} where {T<:Integer}

function all_your_base(
    digits::AVInt{T},
    base_in::Integer,
    base_out::Integer,
) where {T<:Integer}
    check_valid_bases(base_in, base_out)
    return all_your_base(digits, UInt(base_in), UInt(base_out))
end

function all_your_base(digits::AVInt{T}, base_in::UInt, base_out::UInt) where {T<:Integer}
    return encode(decode(digits, base_in), base_out, T)
end

function all_your_base(::AbstractVector{Bool}, base_in::Integer, base_out::Integer)
    throw(ArgumentError("digits must be integers, not Bool"))
end

function all_your_base(digits::Any, base_in::Integer, base_out::Integer)
    check_valid_bases(base_in, base_out)
    isempty(digits) && return [0]
    throw(DomainError(digits, "Not supported"))
end

function decode(digits::AVInt{T}, base_in::UInt) where {T<:Integer}
    result = (zero ∘ widen)(T)

    for digit ∈ digits
        0 ≤ digit < base_in ||
            throw(DomainError(digit, "digit is not compatible with base $base_in"))
        result = result * base_in + digit
    end
    return result
end

function encode(number::Integer, base_out::UInt, ::Type{T}) where {T<:Integer}
    iszero(number) && return [zero(T)]

    n_digits = Base.ndigits(number; base = base_out)
    results = zeros(T, n_digits)
    ix = n_digits

    while number > 0
        (number, rem) = divrem(number, base_out)
        results[ix] = rem
        ix -= 1
    end
    return results
end

check_valid_bases(b_in::Integer, b_out::Integer) =
    (b_in ≤ 1 || b_out ≤ 1) && throw(DomainError((b_in, b_out), "bases should be > 1"))
