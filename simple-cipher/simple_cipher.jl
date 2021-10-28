using Random

const ALPHA = "abcdefghijklmnopqrstuvwxyz0123456789"
const LEN_ALPHA = length(ALPHA)

const L2IX = Dict(k => v for (k, v) in zip(collect(ALPHA), collect(0:LEN_ALPHA - 1)))
const IX2L = Dict(v => k for (k, v) in L2IX)

const NON_ALPHA_REXP = r"[^a-zA-Z0-9]"

const LEN_GEN_KEY = 100

const T_IC = Tuple{Integer, AbstractChar}
const VT_IC = AbstractVector{T_IC}

macro key_checker(fn)
  if typeof(fn) == Expr
    ## extract key and build checker
    # local key = expr.args[1].args[3] # w/o any type annotation
    local key = fn.args[1].args[1].args[3].args[1]

    local genkey = :($(key) === nothing && ($(key) = generate_key()))
    local checkkey = :((length($(key)) < 3 || match(r"\A[a-z0-9]+\z", $(key)) == nothing) &&
      throw(ArgumentError("$($(key)) should be at least of length 4")))

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

## Public API

encode(txt::String) = encode(txt, nothing)

@key_checker function encode(txt::String, key::Union{String, Nothing})::String
  xcode_fn(txt_filtered_to_vec(txt),
           key |> lowercase,
           encode_fn)
end

decode(::String) = throw(ArgumentError("Expecting a key as well for decoding"));

@key_checker function decode(txt::String, key::String)::String
  xcode_fn(txt_filtered_to_vec(txt),
           key |> lowercase,
           decode_fn)
end

## Private helpers

generate_key() = (IX2L[mod(x, LEN_ALPHA)] for x ∈ Random.rand(Int, LEN_GEN_KEY)) |>
    a -> join(a)

xcode_fn(vtxt::VT_IC, key::AbstractString, fn) =
  fn.(vtxt, key) |>
  ixes -> map(ix -> IX2L[ix], ixes) |>
  a -> join(a)

function encode_fn(tuple::T_IC, key::AbstractString)::Integer
  (ix, ch) = tuple
  keylen = length(key)
  (L2IX[ch] + L2IX[key[key_index(ix, keylen)]]) % LEN_ALPHA
end

function decode_fn(tuple::T_IC, key::AbstractString)::Integer
  (ix, ch) = tuple
  keylen = length(key)
  mod((L2IX[ch] - L2IX[key[key_index(ix, keylen)]]), LEN_ALPHA)
end

@inline function txt_filtered_to_vec(txt::String)::VT_IC
  lowercase(txt) |>
    t -> replace(t, r"[^a-z0-9]" => "") |>
    t -> enumerate(t) |>
    collect
end

@inline function key_index(ix::Integer, keylen::Integer)::Integer
  kx = ix % keylen
  kx == zero(eltype(ix)) ? one(eltype(ix)) : kx
end
