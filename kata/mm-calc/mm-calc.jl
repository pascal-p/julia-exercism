
import Base: +, -, *, /, %

# we need a sentinel to avoid a loop with Base:+
# any character is fine for the string to build
+(x::Unsigned, y::Unsigned, ::Symbol)::Integer = string(repeat(".", x), repeat(".", y)) |> length

function -(x::Unsigned, y::Unsigned, ::Symbol)::Integer
  y == 0 && return x

  if lesser(x, y)
    l = split(repeat("1", y), repeat("1", x), limit=2)[end] |> length
    return -l
  end
  # lesser(x, y) is false ≡ x > y
  split(repeat("1", x), repeat("1", y), limit=2)[end] |> length
end

*(x::Unsigned, y::Unsigned, ::Symbol)::Integer = repeat(repeat(".", x), y) |> length

function /(x::Unsigned, y::Unsigned, ::Symbol) #::Float64
  y == zero(Unsigned) && return NaN

  (x, q) = yadiv(x, y, zero(Unsigned)) # quotient
  (x, r₁) = yadiv(*(x, unsigned(10), :sentinel) |> unsigned, y, zero(Unsigned)) # first decimal
  (_, r₂) = yadiv(*(x, unsigned(10), :sentinel) |> unsigned, y, zero(Unsigned)) # second decimal
  parse(Float64, string(q, ".", r₁, r₂))
end

function yadiv(x::Unsigned, y::Unsigned, q::Unsigned)
  lesser(x, y) && (return (x, q))
  yadiv(-(x, y, :op) |> unsigned, y, incr(q))
end

function %(x::Unsigned, y::Unsigned, ::Symbol)::Union{Float64, Integer}
  y == zero(Unsigned) && (return NaN)

  (x, _) = yadiv(x, y,  zero(Unsigned))
  Integer(x)
end

decr(x::Unsigned)::Unsigned = x == 0 ? x : (x -= 1)

incr(x::Unsigned)::Unsigned = x += 1


"""
  lesser(x, y) is true if x is (strictly) less than y
"""
lesser(x::Unsigned, y::Unsigned)::Bool = lesser(decr(x), decr(y), x, y)

function lesser(x::Integer, y::Integer)::Bool
  @assert x == abs(x) && y == abs(y)
  lesser(unsigned(x), unsigned(y))
end

function lesser(x::Unsigned, y::Unsigned, xprev::Unsigned, yprev::Unsigned)::Bool
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
  "%" => %
)

calc(x::Unsigned, y::Unsigned, op::String) = OpMap[op](x, y, Symbol(op))

function calc(x::Integer, y::Integer, op::String)
  @assert x == abs(x) && y == abs(y)
  calc(unsigned(x), unsigned(y), op)
end
