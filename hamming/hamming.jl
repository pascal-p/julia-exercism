"""
Calculate Hamming distance between 2 DNA-String (aka strand)
of equals length. Assuming both strand are valid

E.g.
  GAGCCTACTAACGGGAT
  CATCGTAATGACGGCCT
  ^ ^ ^  ^ ^    ^^

  distance("GAGCCTACTAACGGGAT", "CATCGTAATGACGGCCT") == 7
"""

function distance(a::String, b::String)::Integer
  length(a) != length(b) && throw(ArgumentError("strand must have the same length"))
  a == b && return 0  # encompasses # a == "" && b == "" && return 0

  return reduce(+,
                map((tch) -> tch[1] == tch[2] ? 0 : 1, zip(a, b));
                init=0)
end
