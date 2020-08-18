"""
  Rational numbers: RationalNumber{T<:Integer} <: Real
    Rational number type, with numerator and denominator of type `T`.

  Caveat no Float management beyond power operation at this stage...
  Trying to avoid overflow...
"""

using InteractiveUtils


import Base: <, ≤, >, ≥, ==, ≠
import Base: +, -, *, /, //
import Base: promote_rule, typemin, typemax, show, write, read


const SIGNED_INT_LE64 = (Int8, Int16, Int32, Int64)
const STYPES = sort(subtypes(Signed), lt=(x, y) -> ≤(sizeof(x), sizeof(y)), rev=false)


struct RationalNumber{T<: Integer} <: Real
  num::T
  den::T

  function RationalNumber(num::T, den::T) where {T <: Integer}
    den == zero(typeof(den)) && throw(ArgumentError("[1] Denominator cannot be 0 (num: $num, den: $den)"))
    den == num && return new{T}(Base.one(T), Base.one(T))

    ## get and change sign avoiding possible overflow
    sign = 1
    den, promoted_den, sign = promote_get_sign(den, sign)
    num, promoted_num, sign = promote_get_sign(num, sign)

    ## promote num if den was promoted and vice-versa
    num, promoted_num = promote_other(den, promoted_den, num, promoted_num)
    den, promoted_den = promote_other(num, promoted_num, den, promoted_den)

    ## simplify
    (num, den) = _div_by_gcd(num, den)

    ## re-apply sign
    num = sign < 0 ? num * sign : num

    if promoted_den  ## or promoted_num
      tn = typeof(den)
      new{tn}(tn(num), tn(den))
    else
      new{T}(num, den)
    end
  end
end

RationalNumber(r::RationalNumber) = r  ## Identity

RationalNumber(x::Integer) = RationalNumber(x, Base.one(Integer))

for (FT, TT) in zip(STYPES[1:(end - 1)], STYPES[2:end])
  @eval begin
    RationalNumber(x::$FT, y::$TT) = RationalNumber($TT(x), y)
    RationalNumber(x::$TT, y::$FT) = RationalNumber(x, $TT(y))
  end
end

for (FT, TT) in ((Int8, Int), (Int16, Int), (Int32, Int), (Int, BigInt)) # remainder Int == Int64 (machine dependent)
  @eval begin
    RationalNumber(x::$FT, y::$TT) = RationalNumber($TT(x), y)
    RationalNumber(x::$TT, y::$FT) = RationalNumber(x, $TT(y))
  end
end


##
## Promotion rules
##
promote_rule(::Type{RationalNumber{T}}, ::Type{S}) where {T<:Integer,S<:Integer} = RationalNumber{promote_type(T,S)}
promote_rule(::Type{RationalNumber{T}}, ::Type{RationalNumber{S}}) where {T<:Integer, S<:Integer} = RationalNumber{promote_type(T,S)}
promote_rule(::Type{RationalNumber{T}}, ::Type{S}) where {T<:Integer,S<:AbstractFloat} = promote_type(T, S)


##
## Relational
##
Base.zero(::Type{RationalNumber{T}}) where {T <: Integer}  = RationalNumber(0, 1)
Base.one(::Type{RationalNumber{T}}) where {T <: Integer} = RationalNumber(1, 1)

Base.isone(r::RationalNumber{T}) where {T <: Integer} = isone(r.num) && isone(r.den)
Base.iszero(r::RationalNumber{T}) where {T <: Integer} = iszero(r.num)

function Base.abs(r::RationalNumber{T}) where {T <: Integer}
  function _abs(x::Integer)::Integer
    num = abs(x)
    if signbit(num)
      if x ∈ SIGNED_INT_LE64
        num = abs(Int128(r.num))

      elseif isa(x, Int128)
        num = abs(BigInt(x))

      end  # No other cases
    end
    num
  end

  num, den = _abs(r.num), _abs(r.den)
  RationalNumber(num, den)
end

for op in (:<, :≤, :>, :≥, :≠)
  @eval begin

    ## rational only
    function ($op)(r₁::RationalNumber, r₂::RationalNumber)::Bool
      ($op)(r₁.num * r₂.den, r₂.num * r₁.den)
    end

    ## mix right
    function ($op)(r::RationalNumber, x::Integer)::Bool
      ($op)(r, RationalNumber(x))
    end

    ## mix left
    function ($op)(x::Integer, r::RationalNumber)::Bool
      ($op)(RationalNumber(x), r)
    end

  end
end

==(r₁::RationalNumber, r₂::RationalNumber) = r₁.num == r₂.num && r₁.den == r₂.den
==(r::RationalNumber, x::Integer) = ==(r, RationalNumber(x))
==(x::Integer, r::RationalNumber) = ==(RationalNumber(x), r)



##
## Arithmetic
##
function mul_checked(x::Integer, y::Integer)::Integer
  """Signed integers ONLY"""
  r = op_checked(*, x, y)
  r
end

function add_checked(x::Integer, y::Integer)::Integer
  """Signed integers ONLY"""
  r = op_checked(+, x, y)
  r
end

function sub_checked(x::Integer, y::Integer)
  """Signed integers ONLY"""
  r = x - y

  if typeof(x) ∈ SIGNED_INT_LE64 && typeof(y) ∈ SIGNED_INT_LE64 && r == Int128(x) - y # y will be promoted
    r  # no overflow for Int64

  elseif typeof(x) ∈ STYPES && typeof(y) ∈ STYPES && r == BigInt(x) - y
    r  # no overflow for Int128

  elseif x == 0 || y == 0
    r
  elseif x < 0 && y > 0 && r > 0  # r should be <0!
    r = _retry(-, r, x, y)

  elseif x > 0 && y < 0 && r < 0  # r should be >0!
    r = _retry(-, r, x, y)

  elseif x < 0 && y < 0 && r > 0
    r = _retry(-, r, x, y)

  elseif x > 0 && y > 0 && r < 0
    r = _retry(-, r, x, y)

  #else
  #  throw(ArgumentError("Not yet implemented for op - "))
  end

  r
end

function op_checked(op, x::Integer, y::Integer)::Integer
  r::Integer = op(x, y)

  if typeof(x) ∈ SIGNED_INT_LE64 && typeof(y) ∈ SIGNED_INT_LE64 && r == op(Int128(x), y) # y will be promoted
    r  # no overflow for Int64

  elseif typeof(x) ∈ subtypes(Signed) && typeof(y) ∈ subtypes(Signed) && r == op(BigInt(x), y)
    r  # no overflow for Int128

  elseif x > 0 && y > 0
    r = _retry(op, r, x, y)

  elseif x ≥ 0 && y < 0 || x < 0 && y ≥ 0  # no overflow expected for addition
    if op == +
      r
    elseif op == *  # overflow possible for multiplication
      r = r ≥ 0 ? _retry(op, r, x, y) : r    # was >
    else
      throw(MethodError("op $(op) not yet implemented"))
    end

  else  # x ≤ 0 && y ≤ 0 => overflow will wrap onto positive interval
    if r ≥ 0  ## overflow!
      typeof(r) == Int64 && (r = op(Int128(x), Int128(y)))
      r ≥ 0 && typeof(r) == Int128 && (r = op(BigInt(x), BigInt(y)))
    end
  end
  r
end

function _retry(op, r::Integer, x::Integer, y::Integer)::Integer
  if r == 0 && x ≠ 0 && y ≠ 0
    typeof(r) == Int64 && (r = op(Int128(x), Int128(y)))
    # is r still 0? x ≠ 0 && y ≠ 0 still...
    r == 0 && typeof(r) == Int128 && (r = op(BigInt(x), BigInt(y)))

  elseif r < x || r < y
    typeof(r) == Int64 && (r = op(Int128(x), Int128(y)))                       # Redo with Int128

    (r < x || r < y) && typeof(r) == Int128 && (r = op(BigInt(x), BigInt(y)))  # Redo with BigInt
  else
    r  # looks ok
  end

  r
end

## Avoid overflow whenever possible...
for (op, opchk) in ((:+, add_checked), (:-, sub_checked))
  @eval begin
    ($op)(r₁::RationalNumber, r₂::RationalNumber) = RationalNumber(($opchk)(mul_checked(r₁.num, r₂.den), mul_checked(r₁.den, r₂.num)),
                                                                   mul_checked(r₁.den, r₂.den))

    ($op)(r::RationalNumber, x::Integer) = ($op)(r, RationalNumber(Integer(x)))

    ($op)(x::Integer, r::RationalNumber) = ($op)(RationalNumber(Integer(x)), r)
  end
end

for op in (:*,)
  @eval begin
    ($op)(r₁::RationalNumber, r₂::RationalNumber) = RationalNumber(mul_checked(r₁.num, r₂.num),
                                                                   mul_checked(r₁.den, r₂.den))

    ($op)(r::RationalNumber, x::Integer) = ($op)(r, RationalNumber(Integer(x)))

    ($op)(x::Integer, r::RationalNumber) = ($op)(RationalNumber(Integer(x)), r)
  end
end

function Base.:/(r₁::RationalNumber{T}, r₂::RationalNumber{T}) where {T <: Integer}
  r₂.num == 0 && throw(ArgumentError("[2] Denominator cannot be 0"))
  RationalNumber(r₁.num * r₂.den, r₁.den * r₂.num)
end

function Base.:^(r::RationalNumber{T}, x::Integer) where {T <: Integer}
  iszero(r) && iszero(x) && throw(ArgumentError("Undefined from 0^0"))
  iszero(x) && return one(RationalNumber{T})

  RationalNumber(r.num ^ x, r.den ^ x)
end

function Base.:^(r::RationalNumber{T}, x::AbstractFloat) where {T <: Integer}
  iszero(r) && iszero(x) && throw(ArgumentError("Undefined from 0^0"))
  iszero(x) && return one(AbstractFloat)

  r.num^x / r.den^x
end

function Base.:^(x::Integer, r::RationalNumber{T}) where {T <: Integer}
  iszero(x) && iszero(r) && throw(ArgumentError("Undefined from 0^0"))
  iszero(r) && return AbstractFloat(1)
  isone(r) && return AbstractFloat(x)

  x ^ (r.num / r.den)
end

function Base.:^(x::AbstractFloat, r::RationalNumber{T}) where {T <: Integer}
  iszero(x) && iszero(r) && throw(ArgumentError("Undefined from 0^0"))
  iszero(r) && return AbstractFloat(1)
  isone(r) && return x

  (x ^ r.num) ^ (1 / r.den)
end


"""
    //(num, den)

Divide two integers or rational numbers, giving a [`Rational`](@ref) result.

# Examples
```jldoctest
julia> 3 // 5
3//5

julia> (3 // 5) // (2 // 1)
3//10
```
"""
//(n::Integer,  d::Integer) = RationalNumber(n, d)

//(r::RationalNumber, x::Integer) = r / RationalNumber(x)

//(x::Integer,  r::RationalNumber) = RationalNumber(x) / r

//(r₁::RationalNumber, r₂::RationalNumber) = r₁ / r₂


## unary
+(x::RationalNumber) = RationalNumber(+x.num, x.den)
-(x::RationalNumber) = RationalNumber(-x.num, x.den)


##
## Others
##
numerator(x::Integer) = x
numerator(r::RationalNumber{T}) where {T <: Integer} = r.num

denominator(x::Integer) = one(x)
denominator(r::RationalNumber{T}) where {T <: Integer} = r.den

typemin(::Type{RationalNumber{T}}) where {T <: Signed} = RationalNumber(typemin(T), one(T))
typemin(::Type{RationalNumber{T}}) where {T <: Integer} = RationalNumber(zero(T), one(T))     ## Actually Unsigned
typemax(::Type{RationalNumber{T}}) where {T <: Integer} = RationalNumber(typemax(T), one(T))

Base.show(io::IO, r::RationalNumber{T}) where {T <: Integer} = print(io, "$(r.num)//$(r.den)")

function read(s::IO, ::Type{RationalNumber{T}}) where T<:Integer
  r = read(s, T)
  i = read(s, T)
  r//i
end

write(s::IO, r::RationalNumber) = write(s, numerator(r), denominator(r))

##
## Utils
##

function _div_by_gcd(n::Integer, d::Integer)::Tuple{Integer, Integer}
  n, d = abs(n), abs(d)
  x = _gcd(n, d)
  abs(x) == 1 ? (n, d) : (div(n, x), div(d, x))
end

function _gcd(n::Integer, d::Integer)::Integer
  """
  Calculate gcd(n, d)
  """
  n, d = n < d ? (d, n) : (n, d)
  iszero(d) && return n

  r = n
  while r > 1
    r = n % d
    n, d = d, r    
  end

  return r == 0 ? n : r
end


function promote_get_sign(n::Integer, sign)

  function _promote(n::Integer)
    if isa(n, BigInt)
      n
    elseif n == typemin(typeof(n))
      promote_f_t(n)
    else
      n
    end
  end

  promoted = false
  if n < 0
    sign *= -1
    n = _promote(n) * -1 # n = promote_f_t(n) * -1
    @assert n > 0
    promoted = true
  end

  n, promoted, sign
end

function promote_other(this, promoted, other, promoted_other)
  if promoted && !promoted_other
    other = typeof(this)(other)
    promoted_other = true
  end

  other, promoted_other
end

## No advantage in defining a macro
# macro promote_f_t(n)
#   quote
#     local stypes = sort(subtypes(Signed), lt=(x, y) -> ≤(sizeof(x), sizeof(y)), rev=false)

#     for (type_f, type_t) in zip(stypes[1:end-1], stypes[2:end])
#       isa($(esc(n)), type_f) && return type_t($(esc(n)))
#     end
#   end
# end

function promote_f_t(n::Signed)::Signed
  for (type_f, type_t) in zip(STYPES[1:end-1], STYPES[2:end])
    isa(n, type_f) && return type_t(n)
  end
  n
end
