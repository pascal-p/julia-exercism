using Random

const ALPHA = "abcdefghijklmnopqrstuvwxyz0123456789"
const LEN_ALPHA = length(ALPHA)

const L2IX = Dict(k => v for (k, v) in zip(collect(ALPHA), collect(0:LEN_ALPHA - 1)))
const IX2L = Dict(v => k for (k, v) in L2IX)

const NON_ALPHA_REXP = r"[^a-zA-Z0-9]"

const LEN_GEN_KEY = 100

macro key_checker(fn)
  if typeof(fn) == Expr
    ## extract key and build checker
    # local key = expr.args[1].args[3] # w/o any type annotation
    local key = fn.args[1].args[1].args[3].args[1]

    local genkey = :($(key) === nothing && ($(key) = generate_key()))
    local checkkey = :(length($(key)) < 3 && throw(ArgumentError("$($(key)) should be at least of length 4")))

    ## Inject checker in body of wrapped function
    ## fn.args[2] is the body of the initial function
    fn.args[2] = :(begin
      $(genkey)
      $(checkkey)
      $(fn.args[2])
    end)
  end

  fn
end

encode(txt::String) = encode(txt, nothing)

@key_checker function encode(txt::String, key::Union{String, Nothing})::String
  encode_fn(enumerate(txt) |> collect, key |> lowercase)
end

@key_checker function decode(txt::String, key::String)::String
  # TODO
end

## Private helpers

generate_key() = (IX2L[mod(x, LEN_ALPHA)] for x ∈ Random.rand(Int, LEN_GEN_KEY)) |>
    a -> join(a)

encode_fn(vtxt::AbstractVector, key::AbstractString) =
  encode_fn.(vtxt, key) |>
  ixes -> map(ix -> IX2L[ix], ixes) |>
  a -> join(a)

function encode_fn(tuple::Tuple{Integer, AbstractChar}, key::AbstractString)::Integer
  (ix, ch) = tuple
  keylen = length(key)
  kx = ix % keylen
  kx == 0 && (kx = 1)
  (L2IX[lowercase(ch)] + L2IX[key[kx]]) % LEN_ALPHA
end

function decode_fn(ix::Integer, ch::AbstractChar, key::AbstractString)::AbstractChar
  keylen = length(key)
  mod((L2IX[ch] - L2IX[key[ix % keylen]]), LEN_ALPHA)
end
