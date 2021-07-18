const DIRS = [7, 0, 1, 6, -1, 2, 5, 4, 3] # cf. check_matching_dir...

const NT_RANGE = NamedTuple{(:_start, :_end), Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}
const NT_DIM = NamedTuple{(:nrows, :ncols), Tuple{Int64, Int64}}

const DM = Union{Nothing, Dict{String, NT_RANGE}}

macro for_(expr, body)
  quote
    $(esc(expr.args[1]))        # init

    while $(esc(expr.args[3]))  # loop
      $(esc(body))
      $(esc(expr.args[5]))      # update
    end
  end
end

struct WordSearch
  grid::AbstractVector{AbstractString}
  dim::NT_DIM
end

WordSearch(grid::AbstractVector{<: AbstractString}) = WordSearch(grid, (nrows=length(grid), ncols=length(grid[1])))

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
  Directions are as follows:

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
    (flag, jx, frow, fcol) = _dir_dia_up(ws, word, (ix, jx), coord, frow, fcol, lim)
    !flag && return nothing

  elseif coord.dir ∈ (2, 6)
    (flag, jx, fcol) = _dir_left_right(ws, word, (ix, jx), coord, fcol, lim)
    !flag && return nothing

  elseif coord.dir ∈ (3, 7)
    (flag, jx, frow, fcol) = _dir_dia_down(ws, word, (ix, jx), coord, frow, fcol, lim)
    !flag && return nothing

  else
    nothing # or exception?
  end

  jx > lim ? (frow, fcol) : nothing
end

function _dir_up_down(ws::WordSearch, word::AbstractString, tix::Tuple{Int, Int}, coord::NamedTuple, frow, lim)
  (ix, jx) = tix
  range = if coord.dir == 0
    coord.row:-1:1
  elseif coord.dir == 4
    coord.row:ws.dim.nrows
  else
    throw(ArgumentError("direction $(coord.dir) is not meaningful in this function context"))
  end

  for r ∈ range
    jx > lim && break
    word[jx] != ws.grid[r][coord.col] && return (false, nothing, nothing)
    jx += 1
    frow = r
  end
  (true, jx, frow)
end

function _dir_left_right(ws::WordSearch, word::AbstractString, tix::Tuple{Int, Int}, coord::NamedTuple, fcol, lim)
  (ix, jx) = tix
  range = if coord.dir == 2
    coord.col:ws.dim.ncols
  elseif coord.dir == 6
    coord.col:-1:1
  else
    throw(ArgumentError("direction $(coord.dir) is not meaningful in this function context"))
  end

  for c ∈ range
    jx > lim && break
    word[jx] != ws.grid[coord.row][c] && return (false, nothing, nothing)
    jx += 1
    fcol = c
  end
  (true, jx, fcol)
end

function _dir_dia_up(ws::WordSearch, word::AbstractString, tix::Tuple{Int, Int}, coord::NamedTuple, frow, fcol, lim)
  local (ix, jx) = tix
  if coord.dir == 1
    @for_ ((r, c) = (coord.row, coord.col); r ≥ 1 && c ≤ ws.dim.ncols; (r -= 1, c += 1)) begin
      jx > lim && break
      word[jx] != ws.grid[r][c] && return (false, jx, nothing, nothing)
      jx += 1
      (frow, fcol) = (r, c)
    end
  elseif coord.dir == 5
    @for_ ((r, c) = (coord.row, coord.col); r ≤ ws.dim.ncols && c ≥ 1; (r += 1, c -= 1)) begin
      jx > lim && break
      (word[jx] != ws.grid[r][c]) && return (false, jx, nothing, nothing)
      (frow, fcol) = (r, c)
      jx += 1
    end
  else
    throw(ArgumentError("direction $(coord.dir) is not meaningful in this function context"))
  end
  (true, jx, frow, fcol)
end

function _dir_dia_down(ws::WordSearch, word::AbstractString, tix::Tuple{Int, Int}, coord::NamedTuple, frow, fcol, lim)
  (ix, jx) = tix
  if coord.dir == 3
    @for_ ((r, c) = (coord.row, coord.col); r ≤ ws.dim.nrows && c ≤ ws.dim.ncols; (r += 1, c += 1)) begin
      jx > lim && break
      word[jx] != ws.grid[r][c] && return (false, jx, nothing, nothing)
      jx += 1
      (frow, fcol) = (r, c)
    end
  elseif coord.dir == 7
    @for_ ((r, c) = (coord.row, coord.col); r ≥ 1  && c ≥ 1; (r -= 1, c -= 1)) begin
      jx > lim && break
      word[jx] != ws.grid[r][c] && return (false, jx, nothing, nothing)
      jx += 1
      (frow, fcol) = (r, c)
    end
  else
    throw(ArgumentError("direction $(coord.dir) is not meaningful in this function context"))
  end
  (true, jx, frow, fcol)
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
