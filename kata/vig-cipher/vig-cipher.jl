import Base: -

const T = UInt8

struct CharMatrix
  matrix::Vector{Vector{Char}} # or T? => ByteMatrix
  size::UInt
end

const LETTER2CODE = Dict{Char, Int8}(
  l => i - 1 for (i, l) ∈ enumerate('A':'Z' |> collect)
)

const CODE2LETTER = Dict{Int8, Char}(
  i - 1 => l for (i, l) ∈ enumerate('A':'Z' |> collect)
)

const ALPHALEN = LETTER2CODE |> length

# src: https://en.wikipedia.org/wiki/Letter_frequency
# Relative frequency in the English language in Texts
LETTERFREQ = Dict{Char, Float32}(
  'A' => 0.082f0,
  'B' => 0.015f0,
  'C' => 0.028f0,
  'D' => 0.043f0,
  'E' => 0.13f0,
  'F' => 0.022f0,
  'G' => 0.02f0,
  'H' => 0.061f0,
  'I' => 0.07f0,
  'J' => 0.0015f0,
  'K' => 0.0077f0,
  'L' => 0.04f0,
  'M' => 0.024f0,
  'N' => 0.067f0,
  'O' => 0.075f0,
  'P' => 0.019f0,
  'Q' => 0.00095f0,
  'R' => 0.06f0,
  'S' => 0.063f0,
  'T' => 0.091f0,
  'U' => 0.028f0,
  'V' => 0.0098f0,
  'W' => 0.024f0,
  'X' => 0.0015f0,
  'Y' => 0.02f0,
  'Z' => 0.00074f0,
)


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
    diff[ix] = CODE2LETTER[(LETTER2CODE[c₁] - LETTER2CODE[c₂] + ALPHALEN) % ALPHALEN] |> string
  end
  join(diff, "")
end

function splitbygroup(s::AbstractString, klen::UInt)::CharMatrix
  v = [Char[] for _ ∈ 1:klen]

  for (ix, ch) ∈ enumerate(s)
    push!(v[(ix % klen) == 0 ? klen : ix % klen], ch)
  end

  CharMatrix(v, klen)
end

splitbygroup(s::AbstractString, klen::Integer) = splitbygroup(s, UInt(klen))

function joinfromgroup(v::CharMatrix)::AbstractString
  n = sum(length, v.matrix) ## tot. num. of chars
  vs = fill("", n)

  ix = 1
  for cix ∈ 1:maximum(length, v.matrix), gix ∈ 1:length(v.matrix)
    cix >  length(v.matrix[gix]) && continue
    vs[ix] = v.matrix[gix][cix] |> string
    ix += 1
  end

  join(vs, "")
end

function calc_freq(s::AbstractString)
  dfreq = Dict{Char, Number}()
  for ch ∈ s
    if haskey(dfreq, ch)
      dfreq[ch] += 1
    else
      dfreq[ch] = 1
    end
  end
  n = length(dfreq)
  for k ∈ keys(dfreq)
    dfreq[k] /= n
  end
  dfreq
end

#
# Brute Force Approach - what does it mean for dec to "make sense"?
#
function recoverkey(s::AbstractString, klen::UInt)
  cm =  splitbygroup(s, klen)
  found, fkey = false, nothing # final key

  function unroll(gix, prevgps, pkey) # potential key
    if gix > cm.size
      pcm = CharMatrix(prevgps, klen) # potential cm
      dec = joinfromgroup(pcm)
      # if dec "make sense" => stop
      return dec[1:6] == "HELLOW" # "ATTA"
    end

    for k ∈ 0:(ALPHALEN - 1)
      cg = map(ch -> transcode(ch |> string, CODE2LETTER[k] |> string, -)[1], cm.matrix[gix])
      found = unroll(gix + 1, [prevgps..., cg], string(pkey, CODE2LETTER[k]))
      !found && continue
      fkey = fkey === nothing ? string(pkey, CODE2LETTER[k]) : fkey
      break
    end
    found
  end

  unroll(1, [], "") && return fkey
  throw(ArgumentError("key could not be found"))
end

recoverkey(s::AbstractString, klen::Integer) = recoverkey(s, UInt(klen))

#
# this part is from ChatGPT - redacted as it was not working and requires
# more work to make if work
#
# ChatGPT is inventing some functions, such as ord, chr, indmax (=> Python)
# Style is really Python-like
#
# Interesting
#
function decode_vigenere(message::String, key::String)
  # Convert message and key to arrays of integers
  message_int = split(message, "") |> vm -> map(ch -> ch[1], vm)
  key_int = split(key, "") |> vm -> map(ch -> ch[1], vm)

  # Repeat the key as needed to match the length of the message
  n = length(message)
  key_int = repeat(key_int, outer=(div(n,length(key)) + 1))[1:n]

  # Subtract key from message to get decoded message
  decoded_int = [
    (c_ = Int((26 + c - k) % 26)) == 0 ? 1 : c_ for (c, k) ∈ zip(message_int, key_int)
  ]

  # Convert decoded message back to a string
  join([string(c + 'A') for c in decoded_int], "") # String([chr(c + 65) for c in decoded_int])
end

function recover_vigenere_key(ciphered::String)
  # Find the key length using the index of coincidence
  n = length(ciphered)
  iocs = []
  for k ∈ 2:floor(Int, n/2)
    # Split the message into k substrings
    substrings = [ciphered[i:(i+k < n ? i+k : i)] for i in 1:k:n]

    # Calculate the index of coincidence for each substring
    iocs_k = sum([sum([ciphered[i] == ciphered[i+k < n ? i+k : i] for i in 1:k]) for k in 1:length(substrings)]) / (k * (k-1))

    # Store the index of coincidence for this key length
    push!(iocs, iocs_k)
  end
  # Find the key length that gives the highest index of coincidence
  println("iocs: $(iocs)")
  key_length = argmax(iocs) + 4 # indmax(iocs) + 1
  println("key_length: $(key_length)")

  # Split the message into key_length substrings
  substrings = [ciphered[i:(i+key_length < n ? (i+key_length) : i)] for i in 1:key_length:n]
  println("substrings: $(substrings)")

  # Recover the key by solving for the key for each substring
  key = ""
  for substring in substrings
    # Calculate the frequencies of each letter in the substring
    frequencies = Dict()
    for c in substring
      haskey(frequencies, c) ? frequencies[c] += 1 : frequencies[c] = 1
    end

    # Find the letter with the highest frequency
    most_frequent_letter = argmax(p -> p[2], frequencies)[2]
    key_char = string(most_frequent_letter + 'A')

    # Add the key character to the key string
    key = string(key, key_char)
  end
  key
end
