const DIRS = [7, 0, 1, 6, -1, 2, 5, 4, 3];
const DM = Union{Nothing, Dict{Symbol, NamedTuple}}

struct WordSearch
  grid::AbstractVector{AbstractString}
  dim:: NamedTuple(Int, Int)
  # match::DM
end

WordSearch(grid::AbstractVector{<: AbstractString}) = WordSearch(grid, (nrows=length(grid), cols=length(grid[1]))) # , nothing)

function find(ws::WordSearch, words::AbstractVector{<: AbstractString})
  result = Dict{Symbol, NamedTuple}}()
  for word ∈ words
    flag, match = multi_search(ws, word, 1, 0, 0, -1)
    flag && (result[word] = match)
  end
  result
end

function multiSearch(ws::WordSearch, word::AbstractString,
                     ix::Int, row::Int, col::Int, dir::Int)::Tuple{Bool, DM}

  _match::DM = nothing
  for r ∈ row:ws.dim.nrows, c ∈ col:ws.dim.cols
    word[ix] != ws.grid[r, c] && continue

    matches = neighboring_search(word, ix + 1, r, c)

    length(matches) == 0 && continue
    ix += 1

    if _match === nothing
      _match = Dict{Symbol, NamedTuple(word => (_start=[r + 1, c + 1], _end=[]))
    end

    for (rm, cm, dm) ∈ matches # dm is the direction of the match)
      (dir != -1 && dm != dir) && continue

      # check if there is a full match in the given direction!
      check_matching_dir(ws, word, ix, rm, cm, dm) && return (true, _match)
    end

    _match::DM = nothing
    ix = 1
    dir = -1
  end

  (false, nothing)
end

function check_matching_dir(ws::WordSearch, word::AbstractString, ix::Int, rm::Int, cm::Int, dm::Int)
end

function neighboring_search(word::AbstractString, ix::Int, r::Int, c::Int)
end
