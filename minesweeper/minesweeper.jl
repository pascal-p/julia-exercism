const VALID_CHARS = (' ', '*')

function annotate(minefield::Vector{String})::Vector{String}
  nr = length(minefield)
  nr ≤ 0 && return minefield

  nc = length(minefield[1])
  nc ≤ 0 && return minefield

  check_same_length(minefield, nc)

  (all_empty_lines(minefield, nc) || all_stars(minefield, nc)) &&
    return minefield

  check_invalid_chars(minefield)

  annotate!(minefield, nr, nc)
  minefield
end

annotate(minefield::Any) = minefield

function check_same_length(minefield::Vector{String}, nc::Integer)
  all(l -> length(l) == nc, minefield) || throw(ArgumentError("Lines must have the same length"))
end

function check_invalid_chars(minefield::Vector{String})
  for line in minefield, ch in line
    ch ∉ VALID_CHARS && throw(ArgumentError("Invalid character detected"))
  end
end

function all_empty_lines(minefield::Vector{String}, nc::Integer)::Bool
  all(l -> l == VALID_CHARS[1] ^ nc, minefield)
end

function all_stars(minefield::Vector{String}, nc::Integer)::Bool
  all(l -> l == VALID_CHARS[2] ^ nc, minefield)
end

# returns a generator
function neighbors(row::Integer, col::Integer, nr::Integer, nc::Integer)
  (
   (r, c) for r ∈ row-1:row+1,
     c ∈ col-1:col+1 if 1 ≤ r ≤ nr && 1 ≤ c ≤ nc && !(r == row && c == col)
  )
end

function annotate!(minefield::Vector{String}, nr::Integer, nc::Integer)
  for r in 1:nr
    line::String = ""
    for c in 1:nc
      if minefield[r][c] == VALID_CHARS[2]
        line = string(line, VALID_CHARS[2])  ## '*'
        continue
      end

      cnt = zero(typeof(nr))
      for (x, y) in neighbors(r, c, nr, nc)
        minefield[x][y] == VALID_CHARS[2] && (cnt += 1)
      end

      line = if cnt > 0
        string(line, "$(cnt)")
      else
        string(line, minefield[r][c])
      end
    end
    minefield[r] = line
  end
end
