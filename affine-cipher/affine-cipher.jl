const ALPHA = "abcdefghijklmnopqrstuvwxyz"
const M = length(ALPHA)
const L2IX = Dict(k => v for (k, v) in zip(collect(ALPHA), collect(0:M)))
const IX2L = Dict(v => k for (k, v) in L2IX)
const NON_ALPHA_REXP = r"[^a-zA-Z0-9]"
const GRP_SIZE = 5 + 1 # + 1 for space

macro coprime_checker(fn)
  """
  Aim: inject oneliner to check whether the given α (2nd arg of encode/decode function)
  is co-prime with M

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
  if typeof(fn) == Expr
    ## extract var and build checker
    # local var = expr.args[1].args[3] # w/o any type annotation
    local var = fn.args[1].args[1].args[3].args[1]                            # access α
    local check = :(!iscoprime($(var)) && throw(ArgumentError("$($(var)) and M=$(M) not coprime")))

    ## Inject checker in body of wrapped function
    fn.args[2] = :(begin
      $(check)
      $(fn.args[2])
    end)

  end

  return fn
end

##
## Public
##
@coprime_checker function encode(plain::AbstractString, α::Integer, β::Integer)::AbstractString
  """
  E(x) = (α × x + β) ≡ m
  """
  |(plain, α, β, :+) |>
    ary -> reduce((s, c) -> grouping(s, c), ary, init=" ") |>
    s -> strip(s)
end

@coprime_checker function decode(ciphered::AbstractString, α::Integer, β::Integer)::AbstractString
  """
  D(y) = α-¹ × (y - β) ≡ m
  """
  α = xgcd(α, M)[2] # max(xgcd(α, M)[2:3]...)

  |(ciphered, α, β, :-) |>
    ary -> join(ary)
end


##
## Internals
##
function |(src::AbstractString, α::Integer, β::Integer, op::Symbol)
  """
  define a pipeline which takes
    - a src (text) and splits it into its characters
    - a filter which excludes the non alpha characters
    - a translator which encode/decode the characters
  """
  collect(src) |>
    ary -> filter((c) -> match(NON_ALPHA_REXP, string(c)) == nothing, ary) |>
    ary -> map(x -> translate(x, α, β, op), ary)
end

function grouping(s::AbstractString, ch::Char)::AbstractString
  l = length(s) + 1
  l % GRP_SIZE == 0 ? string(s, ch, ' ') : string(s, ch)
end

function translate(x::Char, α::Integer, β::Integer, op::Symbol)
  '0' ≤ x ≤ '9' && (return x)

  (op == :+) ? IX2L[mod(α * L2IX[lowercase(x)] + β, M)] :
    IX2L[mod(α * (L2IX[lowercase(x)] - β), M)]
end

function xgcd(x::Integer, y::Integer)::Tuple{Integer, Integer, Integer}
  """
  Extended GCD(x, y) == α * x + β * y == g

  here y will be 26 (always), g is 1 thus find (α, β) relative integer Z
  such that α × x + β × 26 ≡ 1

  ref. https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
       https://en.wikibooks.org/wiki/Algorithm_Implementation/Mathematics/Extended_Euclidean_algorithm
  """
  x₀, x₁, y₀, y₁ = 0, 1, 1, 0
  while x ≠ 0
    (q, x), y = divrem(y, x), x
    y₀, y₁ = y₁, y₀ - q * y₁
    x₀, x₁ = x₁, x₀ - q * x₁
  end

  (y, x₀, y₀)
end

function gcd(x::Integer, y::Integer)::Integer
  """
  assume x > 0 and y > 0
  """
  x, y = x < y ? (y, x) : (x, y)
  y == 0 && (return x)
  r = x
  while r > 1
    r = x % y
    x, y = y, r
  end
  return r == 0 ? x : r
end

iscoprime(x::Integer)::Bool = gcd(x, M) == 1
