"""
  Atbash Cipher
  Assume only valid char (ascii)

  - Valid input set is given by regexp /[a-zA-Z0-9]+/
  - Ignoring punctuation (comprising space),
  - Ignoring any non ascii letter (but keep the 10 digit)
  - Ignoring case
  - Grouping by 5
"""

const GROUP_FACT = 5

function encode(input::AbstractString; enc=true)::AbstractString
  s = " "

  for ch in input
    !occursin(r"[a-zA-Z0-9]+", string(ch)) && continue

    s = '0' ≤ ch ≤ '9' ? string(s, ch) : string(s, 'z' - lowercase(ch) + 'a')
    enc && length(s) % (GROUP_FACT + 1) == 0  && (s = string(s, ' '))
  end

  return strip(s, ' ')
end

decode(input::AbstractString)::AbstractString = encode(input; enc=false)
