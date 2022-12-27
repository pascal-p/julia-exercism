import Base: +, -, *, /, %, ^

const B = string(:.)
const LIM = 5001
const TEN = parse(Int, string(one(Int), zero(Int))) |> unsigned
const NANY = 0/0

# we need a sentinel to avoid a loop with Base:+
# any character is fine for the string to build
+(x::Unsigned, y::Unsigned, ::Symbol)::Integer = string(repeat(B, x), repeat(B, y)) |> length

function -(x::Unsigned, y::Unsigned, ::Symbol)::Integer
  y == 0 && return x

  if lesser(x, y)
    l = split(repeat(B, y), repeat(B, x), limit=2)[end] |> length
    return -l
  end
  # ¬lesser(x, y) ≡ x ≥ y
  split(repeat("1", x), repeat("1", y), limit=2)[end] |> length
end

*(x::Unsigned, y::Unsigned, ::Symbol)::Integer = repeat(repeat(B, x), y) |> length

function /(x::Unsigned, y::Unsigned, ::Symbol)::Float64
  y == zero(Unsigned) && return NaN

  (x, q) = yadiv(x, y, zero(Unsigned)) # quotient
  (x, r₁) = yadiv(*(x, unsigned(TEN), :sentinel) |> unsigned, y, zero(Unsigned)) # first decimal
  (_, r₂) = yadiv(*(x, unsigned(TEN), :sentinel) |> unsigned, y, zero(Unsigned)) # second decimal
  parse(Float64, string(q, ".", r₁, r₂))
end

function yadiv(x::Unsigned, y::Unsigned, q::Unsigned)
  lesser(x, y) && (return (x, q))
  yadiv(-(x, y, :op) |> unsigned, y, incr(q))
end

function %(x::Unsigned, y::Unsigned, ::Symbol)::Union{Float64, Integer}
  y == zero(Unsigned) && (return NANY)

  (x, _) = yadiv(x, y, zero(Unsigned))
  Integer(x)
end

function ^(x::Unsigned, y::Unsigned, ::Symbol)::Union{Float64, Integer}
  iszero(x) && iszero(y) && (return NANY)
  !iszero(x) && iszero(y) && (return one(Int))
  isone(x) && (return Integer(x))

  Int(yapow(one(x), x, y))
end

function yapow(r::Unsigned, x::Unsigned, y::Unsigned)
  iszero(y) && (return r)

  p = *(r, x, :sentinel) |> unsigned
  !lesser(p, LIM) && throw(ArgumentError("limit reached"))

  yapow(p, x, decr(y))
end

decr(x::Unsigned)::Unsigned = iszero(x) ? x : (x -= one(Unsigned))
incr(x::Unsigned)::Unsigned = x += one(Unsigned)

"""
  lesser(x, y) is true if x is (strictly) less than y
"""
lesser(x::Unsigned, y::Unsigned)::Bool = lesser(decr(x), decr(y), x, y)

function lesser(x::Integer, y::Integer)::Bool
  @assert x == abs(x) && y == abs(y)
  lesser(unsigned(x), unsigned(y))
end

function lesser(x::Unsigned, y::Unsigned, xprev::Unsigned, yprev::Unsigned)::Bool
  # Not using zero
  x == xprev && y != yprev && return true
  x != xprev && y == yprev && return false
  x == xprev && y == yprev && return false

  lesser(decr(x), decr(y), x, y)
end

const OpMap = Dict{String, Function}(
  "+" => +,
  "-" => -,
  "*" => *,
  "/" => /,
  "%" => %,
  "^" => ^
)

function calc(x::Unsigned, y::Unsigned, op::String)
  op ∉ keys(OpMap) && throw(ArgumentError("operator $(op) not (yet?) supported"))

  OpMap[op](x, y, :sentinel)
end
function calc(x::Integer, y::Integer, op::String)
  @assert x == abs(x) && y == abs(y)
  @assert lesser(x, LIM) && lesser(y, LIM)

  calc(unsigned(x), unsigned(y), op)
end
