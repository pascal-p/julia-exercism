"""
Calcluation hamming distance between 2 DNA-String (aka strand)
of equals length

E.g.
  GAGCCTACTAACGGGAT
  CATCGTAATGACGGCCT
  ^ ^ ^  ^ ^    ^^

  distance("GAGCCTACTAACGGGAT", "CATCGTAATGACGGCCT") == 7

"""

function distance(a::String, b::String)::Int

  length(a) != length(b) && throw(ArgumentError("strand must have the same length"))

  a == b && return 0  # encompasses # a == "" && b == "" && return 0

  dist = 0
  for (ch1, ch2) in zip(a, b)
    ch1 != ch2 && (dist += 1)
  end

  return dist
end
