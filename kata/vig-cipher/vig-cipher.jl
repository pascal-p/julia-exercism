
const LETTER2CODE = Dict{Char, Int8}(
  l => i - 1 for (i, l) ∈ enumerate('A':'Z' |> collect)
)

const CODE2LETTER = Dict{Int8, Char}(
  i - 1 => l for (i, l) ∈ enumerate('A':'Z' |> collect)
)

macro compkey(fn::Expr)
  local fn_sign = fn.args[1].args  # == Any[:(encode(s::AbstractString, key::AbstractString)), :AbstractString]

  # fn_sign[1] = :(encode(s::AbstractString, key::AbstractString)) == Expr
  #           .args[1] == :encode
  #           .args[2] == s::AbstractString
  #           .args[3] == key::AbstractString
  local s, key = (fn_sign[1].args[2].args[1], fn_sign[1].args[3].args[1])

  ## replace body which is fn.args[2]
  fn.args[2] = quote
    # inject the check
    klen, slen = length(key), length(s)
    nkey = length(key) < length(s) ? complement(key, slen - klen, klen) : key

    # copy back the original function body
    $(fn.args[2])
  end
  fn
end

@compkey function encode(s::AbstractString, key::AbstractString)::AbstractString
  # slen, nkey injected by macro
  ciphered = fill("", slen) # pre-alloc
  for (ix, (l, k)) in enumerate(zip(s, nkey))
    ciphered[ix] = CODE2LETTER[(LETTER2CODE[l] + LETTER2CODE[k]) % 26] |> string
  end

  join(ciphered, "")
end

@compkey function decode(s::AbstractString, key::AbstractString)::AbstractString
  # slen, nkey injected by macro
  deciphered = fill("", slen) # pre-alloc
  for (ix, (l, k)) in enumerate(zip(s, nkey))
    deciphered[ix] = CODE2LETTER[(LETTER2CODE[l] - LETTER2CODE[k] + 26) % 26] |> string
  end

  join(deciphered, "")
end

function complement(key::AbstractString, n::Integer, klen::Integer)::AbstractString
  (q, r) = divrem(n, klen)
  string(key, repeat(key, q), SubString(key, 1, r))
end
