const VS = Vector{String}
const DIGIT_MAP = Dict{Integer, VS}(
                                    0 => [" _ ", "| |", "|_|", "   "],
                                    1 => ["   ", "  |", "  |", "   "],
                                    2 => [" _ ", " _|", "|_ ", "   "],
                                    3 => [" _ ", " _|", " _|", "   "],
                                    4 => ["   ", "|_|", "  |", "   "],
                                    5 => [" _ ", "|_ ", " _|", "   "],
                                    6 => [" _ ", "|_ ", "|_|", "   "],
                                    7 => [" _ ", "  |", "  |", "   "],
                                    8 => [" _ ", "|_|", "|_|", "   "],
                                    9 => [" _ ", "|_|", " _|", "   "],
                                    )
const N, M = 4, 3


function convert(vstr::VS)::String
  length(vstr) % N == 0  ||
    throw(ArgumentError("input should be of length n, where n is a multiple of $(N)"))

  same_rows_len(vstr)||
    throw(ArgumentError("rows of input should be of length n, where n is a multiple of $(M)"))

  length(vstr) == N && same_rows_len(vstr; multiple=false) && return lookup(vstr)

  # dims ≡ 4 × 3n or dims ≡ 4m x 3n
  dims = (nr=length(vstr), nc=length(vstr[1]))
  rs = ""

  for r ∈ 1:4:dims.nr - N + 1
    for c ∈ 1:M:dims.nc - M + 1
      rs = string(rs,
                  lookup([vstr[ix][c:c + M - 1] for ix ∈ r:r + N - 1])
                 )
    end
    rs = string(rs, ",")
  end

  rs[1:end-1]
end

function lookup(vstr::VS)::String
  for (k, v) ∈ DIGIT_MAP
    vstr == v && return "$(k)"
  end

  "?"
end

function same_rows_len(vstr::VS; multiple=true)::Bool
  multiple ?
    all(map(s -> length(s) % M == 0, vstr)) :
    all(map(s -> length(s) == M, vstr))
end
