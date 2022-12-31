
const LETTER2CODE = Dict{Char, Int8}(
  l => i for (i, l) ∈ enumerate('A':'Z' |> collect)
)

const CODE2LETTER = Dict{Int8, Char}(
  i => l for (i, l) ∈ enumerate('A':'Z' |> collect)
)

function encode(s::AbstractString, key::AbstractString)::AbstractString
  klen, slen = length(key), length(s)
  nkey = length(key) < length(s) ? complement(key, slen - klen, klen) : key

  ciphered = fill("", slen) # pre-alloc
  for (ix, (l, k)) in enumerate(zip(s, nkey))
    ciphered[ix] = CODE2LETTER[(LETTER2CODE[l] + LETTER2CODE[k] - 1) % 26] |> string
  end

  join(ciphered, "")
end

function decode(s::AbstractString, key::AbstractString)::AbstractString
  klen, slen = length(key), length(s)
  nkey = length(key) < length(s) ? complement(key, slen - klen, klen) : key

  deciphered = fill("", slen) # pre-alloc
  for (ix, (l, k)) in enumerate(zip(s, nkey))
    deciphered[ix] = CODE2LETTER[(LETTER2CODE[l] - LETTER2CODE[k] + 27) % 26] |> string
  end

  join(deciphered, "")
end

function complement(key::AbstractString, n::Integer, klen::Integer)::AbstractString
  (q, r) = divrem(n, klen)
  string(key, repeat(key, q), SubString(key, 1, r))
end
