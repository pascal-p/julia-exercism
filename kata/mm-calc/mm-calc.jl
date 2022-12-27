const B = string(:.)
const LIM = 5001
const TEN = parse(Int, string(one(Int), zero(Int))) |> unsigned
const NANY = 0/0

# we need a sentinel to avoid a loop with Base:+
# any character is fine for the string to build
fnadd(x::Unsigned, y::Unsigned, ::Symbol)::Integer = string(repeat(B, x), repeat(B, y)) |> length

function fnsub(x::Unsigned, y::Unsigned, ::Symbol)::Integer
  y == 0 && return x

  if lesser(x, y)
    l = split(repeat(B, y), repeat(B, x), limit=2)[end] |> length
    return -l
  end
  # ¬lesser(x, y) ≡ x ≥ y
  split(repeat("1", x), repeat("1", y), limit=2)[end] |> length
end

fnmul(x::Unsigned, y::Unsigned, ::Symbol)::Integer = repeat(repeat(B, x), y) |> length

function fndiv(x::Unsigned, y::Unsigned, ::Symbol)::Float64
  y == zero(Unsigned) && return NaN

  (x, q) = fndiv(x, y, zero(Unsigned)) # quotient
  (x, r₁) = fndiv(fnmul(x, unsigned(TEN), :sentinel) |> unsigned, y, zero(Unsigned)) # first decimal
  (_, r₂) = fndiv(fnmul(x, unsigned(TEN), :sentinel) |> unsigned, y, zero(Unsigned)) # second decimal
  parse(Float64, string(q, ".", r₁, r₂))
end

function fndiv(x::Unsigned, y::Unsigned, q::Unsigned)
  lesser(x, y) && (return (x, q))
  fndiv(fnsub(x, y, :op) |> unsigned, y, incr(q))
end

function fnmod(x::Unsigned, y::Unsigned, ::Symbol)::Union{Float64, Integer}
  y == zero(Unsigned) && (return NANY)

  (x, _) = fndiv(x, y, zero(Unsigned))
  Integer(x)
end

function fnpow(x::Unsigned, y::Unsigned, ::Symbol)::Union{Float64, Integer}
  iszero(x) && iszero(y) && (return NANY)
  !iszero(x) && iszero(y) && (return one(Int))
  isone(x) && (return Integer(x))

  Int(fnpow(one(x), x, y))
end

function fnpow(r::Unsigned, x::Unsigned, y::Unsigned)
  iszero(y) && (return r)

  p = fnmul(r, x, :sentinel) |> unsigned
  !lesser(p, LIM) && throw(ArgumentError("limit reached"))

  fnpow(p, x, decr(y))
end

decr(x::Unsigned)::Unsigned = iszero(x) ? x : (x -= one(Unsigned))

incr(x::Unsigned)::Unsigned = x += one(Unsigned) # no check

# function incr(x::Unsigned)::Unsigned
#   x += one(Unsigned)
#   !lesser(Int(x), LIM) && throw(ArgumentError("limit reached"))
#   x
# end

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

# dynamically, as we use a pattern to define arithmetic operators
# namely fn<op> where op is add, div, ...
# then we use the alpha. order to inject the symbol (was string)...
const OpMap = Dict{Symbol, Symbol}(
  op => fn for (op, fn) ∈ zip([:+, :/, :%, :*, :^, :-],
                              filter(m -> startswith(string(m), r"\Afn"), names(@__MODULE__))) # alpha order
)

function calc(x::Unsigned, y::Unsigned, op::Symbol)
  op ∉ keys(OpMap) && throw(ArgumentError("operator $(op) not (yet?) supported"))

  getfield(@__MODULE__, OpMap[op])(x, y, :sentinel)
end

function calc(x::Integer, y::Integer, op::Symbol)
  @assert x == abs(x) && y == abs(y)
  @assert lesser(x, LIM) && lesser(y, LIM)

  calc(unsigned(x), unsigned(y), op)
end

#  filter(m -> startswith(string(m), r"\Afn"), names(@__MODULE__))
# 6-element Vector{Symbol}:
#  :fnadd
#  :fndiv
#  :fnmod
#  :fnmul
#  :fnpow
#  :fnsub
#
# getfield(@__MODULE__, :fnmul)(unsigned(2), unsigned(3), :op)
# 6
