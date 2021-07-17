const DIRS = [7, 0, 1, 6, -1, 2, 5, 4, 3];

const NT_RANGE = NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}
const NT_DIM = NamedTuple{(:nrows, :ncols), Tuple{Int64, Int64}}

const DM = Union{Nothing, Dict{String, NT_RANGE}}

struct WordSearch
  grid::AbstractVector{AbstractString}
  dim::NT_DIM
end

WordSearch(grid::AbstractVector{<: AbstractString}) = WordSearch(grid, (nrows=length(grid), ncols=length(grid[1]))) # , nothing)

function find(ws::WordSearch, words::AbstractVector{<: AbstractString})
  result = Dict{Symbol, NT_RANGE}()

  for word ∈ words
    coord = (row=1, col=1)
    dir = -1
    flag, match = multi_search(ws, word, coord, dir)
    flag && (result[Symbol(word)] = match[word])
  end

  length(result) == 0 ? nothing : result
end

function multi_search(ws::WordSearch, word::AbstractString, coord, dir)::Tuple{Bool, DM}
  _match::DM = nothing
  ix = 1

  for r ∈ coord.row:ws.dim.nrows, c ∈ coord.col:ws.dim.ncols
    word[ix] != ws.grid[r][c] && continue

    matches = neighboring_search(ws, word, ix + 1, r, c)

    length(matches) == 0 && continue
    ix += 1
    _match === nothing && (_match = Dict{String, NT_RANGE}(word => (_start=(r, c), _end=(-1, -1))))

    for (rm, cm, dm) ∈ matches # dm is the direction of the match
      (dir != -1 && dm != dir) && continue

      # check if there is a full match in the given direction!
      _coord = (row=rm, col=cm, dir=dm)
      if (_end = check_matching_dir(ws, word, ix, _coord)) !== nothing
        _match[word] = (_start=_match[word]._start, _end=_end)
        return (true, _match)
      end
    end

    _match = nothing
    ix = 1
    dir = -1
  end

  (false, nothing)
end


"""
  Directions as follows:

  | 7 | 0 | 1 |
  |---+---+---|
  | 6 |   | 2 |
  |---+---+---|
  | 5 | 4 | 3 |
"""
function check_matching_dir(ws::WordSearch, word::AbstractString, ix::Int, coord::NamedTuple)
  jx = ix
  lim = word |> length
  (frow, fcol) = (coord.row, coord.col)

  if coord.dir ∈ [0, 4]
    (flag, jx, frow) = _dir_up_down(ws, word, (ix, jx), coord, frow,lim)
    !flag && return nothing

  elseif coord.dir ∈ (1, 5)
    (flag, frow, fcol) = _dir_dia_up(ws, word, (ix, jx), coord, frow, fcol, lim)
    !flag && return nothing

  elseif coord.dir ∈ (2, 6)
    (flag, jx, fcol) = _dir_left_right(ws, word, (ix, jx), coord, fcol, lim)
    !flag && return nothing

  elseif coord.dir ∈ (3, 7)
    (flag, frow, fcol) = _dir_dia_down(ws, word, (ix, jx), coord, frow, fcol, lim)
    !flag && return nothing

  else
    nothing
  end

  jx > lim ? (frow, fcol) : nothing
end

function _dir_up_down(ws::WordSearch, word::AbstractString, tix::Tuple{Int, Int}, coord::NamedTuple, frow, lim)
  (ix, jx) = tix
  if coord.dir == 0
    for r ∈ coord.row:-1:1
      jx > lim && break
      word[jx] != ws.grid[r][coord.col] && return (false, nothing, nothing)
      jx += 1;
      frow = r;
    end

  elseif coord.dir == 4
    for r ∈ coord.row:ws.dim.nrows
      jx ≥ lim && break
      word[jx] != ws.grid[r][coord.col] && return (false, nothing, nothing)
      jx += 1
      frow = r
    end
  end

  (true, jx, frow)
end

function _dir_left_right(ws::WordSearch, word::AbstractString, tix::Tuple{Int, Int}, coord::NamedTuple, fcol, lim)
  (ix, jx) = tix
  if coord.dir == 2
    for c ∈ coord.col:ws.dim.ncols
      jx > lim && break
      word[jx] != ws.grid[coord.row][c] && return (false, nothing, nothing)
      jx += 1
      fcol = c
    end
  elseif coord.dir == 6
    for c ∈ coord.col:-1:1
      word[jx] != ws.grid[coord.row][c] && return (false, nothing, nothing)
      jx += 1
      fcol = c
    end
  end

  (true, jx, fcol)
end

function _dir_dia_up(ws::WordSearch, word::AbstractString, tix::Tuple{Int, Int}, coord::NamedTuple, frow, fcol, lim)
  (ix, jx) = tix
  if coord.dir == 1
    # for (r, c) ∈ (row, col); r >= 0 && c < this.dim[1]; r--, c++)
    (r, c) = (coord.row, coord.col)
    while r ≥ 1 && c ≤ ws.dim.ncols
      jx > lim && break
      word[jx] != ws.grid[r][c] && return (false, nothing, nothing)
      jx += 1
      (frow, fcol) = (r, c)
      r -= 1
      c += 1
    end
  elseif coord.dir == 5
    # for (let [r, c] = [row, col]; r < this.dim[0] && c >= 0; r++, c--)
    (r, c) = (coord.row, coord.col)
    while r ≤ ws.dim.ncols && c ≥ 1
      jx > lim && break
      (word[jx] != ws.grid[r][c]) && return (false, nothing, nothing)
      jx += 1
      (frow, fcol) = (r, c)
      r += 1
      c -= 1
    end
  end

  (true, frow, fcol)
end

function _dir_dia_down(ws::WordSearch, word::AbstractString, tix::Tuple{Int, Int}, coord::NamedTuple, frow, fcol, lim)
  (ix, jx) = tix
  if coord.dir == 3
    # for (let [r, c] = [row, col]; r < this.dim[0] && c < this.dim[1]; r++, c++) {
    (r, c) = (coord.row, coord.col)
    while r ≤ ws.dim.nrows && c ≤ ws.dim.ncols
      jx ≥ lim && break
      word[jx] != ws.grid[r][c] && return (false, nothing, nothing)
      jx += 1
      (frow, fcol) = (r, c)
      c += 1
      r += 1
    end
  elseif coord.dir == 7
    # for (let [r, c] = [row, col]; r >= 0 && c >= 0; r--, c--) {
    (r, c) = (coord.row, coord.col)
    while r ≥ 1  && c ≥ 1
      jx ≥ lim && break
      word[jx] != ws.grid[r][c] && return (false, nothing, nothing)
      jx += 1
      (frow, fcol) = (r, c)
      c -= 1
      r -= 1
    end
  end
  (true, frow, fcol)
end

function neighboring_search(ws::WordSearch, word::AbstractString, ix::Int, rₒ::Int, cₒ::Int)
  matches = []
  ix_dir = 1

  for x ∈ rₒ-1:rₒ+1
    if x ≤ 0 || x > ws.dim.nrows
      ix_dir += 3
      continue
    end

    for y ∈ cₒ-1:cₒ+1
      (y ≤ 0 || y > ws.dim.ncols) && (ix_dir += 1; continue)
      x == rₒ && y == cₒ && (ix_dir += 1; continue)
      word[ix] == ws.grid[x][y] && push!(matches, (x, y, DIRS[ix_dir]))
      ix_dir += 1
    end
  end

  matches
end
