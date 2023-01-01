import Base: -

const LETTER2CODE = Dict{Char, Int8}(
  l => i - 1 for (i, l) ∈ enumerate('A':'Z' |> collect)
)

const CODE2LETTER = Dict{Int8, Char}(
  i - 1 => l for (i, l) ∈ enumerate('A':'Z' |> collect)
)

const ALPHALEN = 26

encode(s::AbstractString, key::AbstractString)::AbstractString = transcode(s, key, +)

decode(s::AbstractString, key::AbstractString)::AbstractString = transcode(s, key, -)

function transcode(s, key, op)
  key = complement(key, length(s) - length(key))
  foldl(
    (a, (ix, (l, k))) -> (a[ix] = (CODE2LETTER[(op(LETTER2CODE[l], LETTER2CODE[k]) + ALPHALEN) % ALPHALEN] |> string); a),
    enumerate(zip(s, key));
    init=fill("", length(s))
  ) |> v -> join(v, "")
end

function complement(key::AbstractString, n::Integer)::AbstractString
  klen = length(key)
  (q, r) = divrem(n, klen)
  string(key, repeat(key, q), SubString(key, 1, r))
end

function -(s₁::AbstractString, s₂::AbstractString)::AbstractString
  diff = fill("", length(s₁))  # s₁ and s₂ have same length
  for (ix, (c₁, c₂)) in zip(s₁, s₂) |> enumerate
    diff[ix] = CODE2LETTER[(LETTER2CODE[c₁] - LETTER2CODE[c₂] + 26) % 26] |> string
  end
  join(diff, "")
end
#
# ciphered = encode("THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG", "LION")
# "EPSDFQQXMZCJYNCKUCACDWJRCBVRWINLOWU"

#  ciphered_shifted_by4 = ciphered[5:end]
# "FQQXMZCJYNCKUCACDWJRCBVRWINLOWU"

# "EPSDFQQXMZCJYNCKUCACDWJRCBVRWINLOWU"[1:end - 4]  - "FQQXMZCJYNCKUCACDWJRCBVRWINLOWU"
# "ZZCGTROOOMAZELCIRGRLBVOAGTIGIMT"
