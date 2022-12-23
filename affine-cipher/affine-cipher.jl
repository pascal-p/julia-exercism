import Base: +, -

const ALPHA = "abcdefghijklmnopqrstuvwxyz"
const M = length(ALPHA)
const L2IX = Dict(k => v for (k, v) in zip(collect(ALPHA), collect(0:M)))
const IX2L = Dict(v => k for (k, v) in L2IX)
const NON_ALPHA_REXP = r"[^a-zA-Z0-9]"
const GRP_SIZE = 5 + 1 # + 1 for space

"""
  Aim: inject oneliner to check whether the given α (2nd arg of encode/decode function) is co-prime with M

With: @coprime_checker function encode(plain::AbstractString, α::Integer, β::Integer)::AbstractString
We have the following:

  fn.args[1]                         == encode(plain::AbstractString, α::Integer, β::Integer)::AbstractString
  fn.args[1].args[1]                 == encode(plain::AbstractString, α::Integer, β::Integer)
  fn.args[1].args[2]                 == AbstractString
  fn.args[1].args[1].args[1]         == encode
  fn.args[1].args[1].args[2]         == plain::AbstractString
  fn.args[1].args[1].args[3]         == α::Integer
  fn.args[1].args[1].args[3].args[1] == α
  fn.args[2]                         == whole body of fn
"""
macro coprime_checker(fn)
  if typeof(fn) == Expr
    ## extract var and build checker
    # local var = expr.args[1].args[3] # w/o any type annotation
    local var = fn.args[1].args[1].args[3].args[1]                            # access α
    local check = :(!iscoprime($(var)) && throw(ArgumentError("$($(var)) and M=$(M) not coprime")))

    fn.args[2] = :(begin
      $(check)       # Inject check as first line in the body of the target function
      $(fn.args[2])  # Copy original function body unchanged
    end)
  end

  fn
end

##
## Public
##
"""
  encode(plain::AbstractString, α::Integer, β::Integer)

  where encode(x, α, β) = (α × x + β) ≡ m
"""
@coprime_checker function encode(plain::AbstractString, α::Integer, β::Integer)::AbstractString
  |(plain, α, β, +) |>
    ary -> reduce((s, c) -> grouping(s, c), ary, init=" ") |>
    s -> strip(s)
end

"""
  decode(ciphered::AbstractString, α::Integer, β::Integer)

  where decode(y, α, β) = α-¹ × (y - β) ≡ m
"""
@coprime_checker function decode(ciphered::AbstractString, α::Integer, β::Integer)::AbstractString
  α = xgcd(α, M)[2] # == max(xgcd(α, M)[2:3]...)

  |(ciphered, α, β, -) |>
    ary -> join(ary)
end


##
## Internals
##
"""
  |(src::AbstractString, α::Integer, β::Integer, op)

  defines a pipeline which takes
    - a src (text) and splits it into its characters
    - a filter which excludes the non alpha characters
    - a translator which encode/decode the characters
"""
function |(src::AbstractString, α::Integer, β::Integer, op::Function)
  collect(src) |>
    ary -> filter((c) -> match(NON_ALPHA_REXP, string(c)) === nothing, ary) |>
    ary -> map(x -> '0' ≤ x ≤ '9' ? x : op(x, α, β), ary)
end

@inline function grouping(s::AbstractString, ch::Char)::AbstractString
  l = length(s) + 1
  l % GRP_SIZE == 0 ? string(s, ch, ' ') : string(s, ch)
end

for op ∈ (:+, :-)
  @eval begin
    ($op)(x::Char, α::Integer, β::Integer) = ($(op) == +) ? IX2L[(α * L2IX[lowercase(x)] + β) % M] :
      IX2L[mod(α * (L2IX[lowercase(x)] - β), M)]
  end
end

"""
  Extended GCD(x, y) == α * x + β * y == g

here y will be 26 (always), g is 1 thus find (α, β) relative integer Z
such that α × x + β × 26 ≡ 1

 ref. https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
      https://en.wikibooks.org/wiki/Algorithm_Implementation/Mathematics/Extended_Euclidean_algorithm
"""
@inline function xgcd(x::Integer, y::Integer)::Tuple{Integer, Integer, Integer}
  x₀, x₁, y₀, y₁ = 0, 1, 1, 0
  while x ≠ 0
    (q, x), y = divrem(y, x), x
    y₀, y₁ = y₁, y₀ - q * y₁
    x₀, x₁ = x₁, x₀ - q * x₁
  end

  (y, x₀, y₀)
end

"""
  Calculate gcd(x, y) assuming x > 0 && y > 0
"""
@inline function gcd(x::Integer, y::Integer)::Integer
  x, y = x < y ? (y, x) : (x, y)
  z₀ = zero(eltype(y))
  y == z₀ && (return x)
  while y > 1
    x, y = y, x % y
  end
  y == z₀ ? x : y
end

iscoprime(x::Integer)::Bool = gcd(x, M) == 1
