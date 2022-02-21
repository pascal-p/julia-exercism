const BLACK = 'B'
const WHITE = 'W'
const NONE = ' '

TT = UInt8

struct Point
  x::TT
  y::TT
end

SP = Set{Union{Point, Nothing}}
VP = Vector{Union{Point, Nothing}}

struct GoBoard
  board::Vector{String}
  x_lim::TT
  y_lim::TT

  function GoBoard(board::Vector{String})
    @assert length(board) > 0
    y_lim = length(board)
    x_lim = length(board[1])
    c_board = [board...]
    new(c_board, x_lim, y_lim)
  end
end

## Public API

function territory(goboard::GoBoard, x::TT, y::TT)::Tuple{Char, SP}
  (!(1 ≤ x ≤ goboard.x_lim) || !(1 ≤ y ≤ goboard.y_lim)) && throw(ArgumentError("Invalid coordinate"))

  goboard.board[y][x] != NONE && return (NONE, Set())

  neighbors = get_neighbors(goboard, x, y)
  length(neighbors) == 0 && return (NONE, Set([Point(x, y)])) # very unlikely, but for board with 1 cell

  count = get_color_partition(goboard, neighbors)
  count[BLACK] > 0 && count[WHITE] == 0 && count[NONE] == 0 && (return (BLACK, Set([Point(x, y)])))
  count[BLACK] == 0 && count[WHITE] > 0 && count[NONE] == 0 && (return (WHITE, Set([Point(x, y)])))

  get_territory(goboard, neighbors)
end

function territory(goboard::GoBoard, x::Integer, y::Integer)
  (x < 1 || y < 1) && throw(ArgumentError("Invalid coordinate"))
  territory(goboard, TT(x), TT(y)) # truncation can happen!
end

function territories(goboard::GoBoard)::Dict{String, Set{Point}}
  # TBD
end

## Private Helpers

function get_neighbors(goboard::GoBoard, x::TT, y::TT)::Vector{Union{Point, Nothing}}
  [Point(x - 1, y), Point(x + 1, y), Point(x, y - 1), Point(x, y + 1)] |>
    l -> filter((p::Point) -> (1 ≤ p.x ≤ goboard.x_lim) && (1 ≤ p.y ≤ goboard.y_lim), l)
end

function get_color_partition(goboard::GoBoard, neighbors::VP)::Dict{Char, TT}
  count = Dict{Char, TT}(BLACK => 0, NONE => 0, WHITE => 0)
  for p ∈ neighbors
    count[goboard.board[p.y][p.x]] += 1
  end
  count
end

function get_territory(goboard::GoBoard, neighbors::VP)::Tuple{Char, SP}
  done, territory = VP(), VP()
  color = ' '

  while length(neighbors) > 0
    p = neighbors[1]
    xy_color = goboard.board[p.y][p.x]
    if color == ' '
      (xy_color) != NONE && (color = xy_color)
    elseif color == WHITE && xy_color == BLACK
      color = NONE
    elseif color == WHITE && xy_color == BLACK
      color = NONE
    end
    if xy_color ∈ (BLACK, WHITE)
      neighbors = [neighbors[2:end]...]
      push!(done, p)
    else
      c_neighbors = [
        ρ for ρ ∈ get_neighbors(goboard, p.x, p.y) if ρ ∉ neighbors && p ∉ done
      ]
      push!(territory, p)
      push!(done, p)
      neighbors = [neighbors[2:end]..., c_neighbors...]
    end
  end

  color == ' ' && (color = NONE)
  (color, Set(territory))
end
