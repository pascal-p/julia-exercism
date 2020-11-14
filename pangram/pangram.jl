"""
    ispangram(input)

Return `true` if `input` contains every alphabetic character (case insensitive).
"""

const LEN_ALPHA = 26

function ispangram(input::String) # ::Bool
  length(input) ≤ LEN_ALPHA && return false

  d = Dict{Char, Int}()
  for ch in lowercase(input)
    !('a' ≤ ch ≤ 'z') && continue

    d[ch] = get(d, ch, 0) + 1
    length(d) == LEN_ALPHA && break # Early stopping
  end

  return length(d) == LEN_ALPHA, d
end
