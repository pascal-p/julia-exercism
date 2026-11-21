const AVInt = AbstractVector{T} where {T<:Integer}

abstract type Style end
struct Imperative <: Style end
struct Functional <: Style end

"""
    all_your_base(digits, base_in, base_out; style::Style = Imperative())

Convert a sequence of `digits` from `base_in` to `base_out`.
Dispatch strategy can be selected via `style = Imperative()` or `style = Functional()`.
"""
function all_your_base(
    digits::AVInt{T},
    base_in::Integer,
    base_out::Integer;
    style::Style = Imperative(),
) where {T<:Integer}
    check_valid_bases(base_in, base_out)
    return all_your_base(digits, UInt(base_in), UInt(base_out); style)
end

function all_your_base(
    digits::AVInt{T},
    base_in::UInt,
    base_out::UInt;
    style::Style = Imperative(),
) where {T<:Integer}
    return encode(style, decode(style, digits, base_in), base_out, T)
end

function all_your_base(
    ::AbstractVector{Bool},
    base_in::Integer,
    base_out::Integer;
    style::Style = Imperative(),
)
    throw(ArgumentError("digits must be integers, not Bool"))
end

function all_your_base(
    digits::Any,
    base_in::Integer,
    base_out::Integer;
    style::Style = Imperative(),
)
    check_valid_bases(base_in, base_out)
    isempty(digits) && return [0]
    throw(DomainError(digits, "Not supported"))
end

"""
    decode(::Style, digits::AbstractVector{T}, base_in::UInt)

Decode `digits` in `base_in` to a widened integer (`widen(T)`).
"""
function decode(::Imperative, digits::AVInt{T}, base_in::UInt) where {T<:Integer}
    result = (zero ∘ widen)(T)

    for digit ∈ digits
        0 ≤ digit < base_in ||
            throw(DomainError(digit, "digit is not compatible with base $base_in"))
        result = result * base_in + digit
    end
    result
end

function decode(::Functional, digits::AVInt{T}, base_in::UInt) where {T<:Integer}
    foldl(digits; init = (zero ∘ widen)(T)) do acc, digit
        0 ≤ digit < base_in ||
            throw(DomainError(digit, "digit is not compatible with base $base_in"))
        acc * base_in + digit
    end
end

"""
    encode(::Style, number::Integer, base_out::UInt, ::Type{T}) -> Vector{T}

Encode non-negative `number` into big-endian digits of type `T` in `base_out`.
"""
function encode(::Imperative, number::Integer, base_out::UInt, ::Type{T}) where {T<:Integer}
    iszero(number) && return [zero(T)]

    n_digits = Base.ndigits(number; base = base_out)
    results = zeros(T, n_digits)
    ix = n_digits

    while number > 0
        (number, rem) = divrem(number, base_out)
        results[ix] = rem
        ix -= 1
    end
    results
end

encode(::Functional, number::Integer, base_out::UInt, ::Type{T}) where {T<:Integer} =
    reverse!(Base.digits(T, number; base = base_out))

check_valid_bases(b_in::Integer, b_out::Integer) =
    (b_in ≤ 1 || b_out ≤ 1) && throw(DomainError((b_in, b_out), "bases should be > 1"))
