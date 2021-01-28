abstract type AbstractGame end;

const Empty_Symb = :_
const NSymb = Union{Symbol, Nothing}

"""
  Tic-tac-toe game
"""
struct Game <: AbstractGame
  n::Int       ## size of board
  board::Vector{Symbol}
  current_winner::Vector{NSymb}

  function Game(n::Int=3)
    @assert n ≥ 3

    board::Vector{typeof(Empty_Symb)} = fill(Empty_Symb, n * n)
    current_winner = [nothing]
    new(n, board, current_winner)
  end
end

function reset!(game::Game, cell::Int)
  @assert 0 ≤ cell < game.n * game.n "Got cell $(cell)!"

  game.board[cell + 1] = Empty_Symb
  game.current_winner[1] = nothing
end

function move!(game::Game, cell::Int, player::Symbol)::Bool
  @assert 0 ≤ cell < game.n * game.n

  if game.board[cell + 1] == Empty_Symb
    game.board[cell + 1] = player
    _is_winning_move(game, cell, player) && (game.current_winner[1] = player)
    return true
  else
    throw(ArgumentError("movde $(cell) already played on $(game.board)"))
  end

  return false
end

function has_empty_cells(game::Game)::Bool
  Empty_Symb ∈ game.board
end

"""
  Number of empty cells in current board
"""
function num_empty_cells(game::Game)::Int
  foldl((c, cell) -> c += cell == Empty_Symb, game.board; init=0)
end

function available_moves(game::Game)::Vector{Int}
  [ix - 1 for (ix, c) in enumerate(game.board) if c == Empty_Symb]
end

function Base.show(io::IO, game::Game)
  n = game.n
  n_digits = length(string(n * n))
  npre, npost = floor(Int, (n_digits + 1) / 2), ceil(Int, (n_digits + 1) / 2)
  println(io, string(string("|", "-" ^ (n_digits + 2)) ^ n, "|"))
  srow = ""
  for row ∈ 1:n
    k = (row - 1) * n
    for c ∈ 1 + k:n + k
      srow = string(srow, "|", " " ^ npre, game.board[c], " " ^ npost)
    end
    srow = string(srow, "|\n")
    srow = string(srow, string("|", "-" ^ (n_digits + 2)) ^ n, "|\n")
  end
  println(io, srow)
  println(io, "")
end

function show_num(io::IO, game::Game)
  ## show_num(Base.stdout, game)
  n = game.n
  n_digits = length(string(n * n))
  max_len = n_digits + 2
  num_board = []
  for jx ∈ 1:n
    row = []
    k = (jx - 1) * n
    for ix ∈ 1 + k:n + k
      s = string(ix - 1)
      push!(row, string(" ", s, " " ^ (max_len - 1 - length(s))))
    end
    push!(num_board, row)
  end
  println(io, string(string("|", '-' ^ (n_digits + 2)) ^ n, "|"))
  for row ∈ num_board
    println(io, string("|", join(row, "|"), "|"))
    println(io, string(string("|", "-" ^ (n_digits + 2)) ^ n, "|"))
  end
  println(io, "")
end


##
## Internal Helpers
##

function _is_winning_move(game::Game, cell::Int, player::Symbol)::Bool
  win_row(game, cell, player) ||
  win_col(game, cell, player) ||
  win_diag(game, cell, player)
end

"""
  Check whether we have n horizontally aligned symbols arounf cell for
  given player
"""
function win_row(game::Game, cell::Int, player::Symbol)::Bool
  n = game.n
  rn = cell ÷ n
  join(game.board[rn * n + 1:(rn + 1) * n], "") == String(player) ^ n
end

function win_col(game::Game, cell::Int, player::Symbol)::Bool
  n = game.n
  cn = cell % n
  join([game.board[c] for c ∈ cn+1:n:n*n], "") == String(player) ^ n
end

"""
  Check whether cel is on the up diag. or down diag.
"""
function win_diag(game::Game, cell::Int, player::Symbol)::Bool
  n = game.n

  # check up. diag,
  diag = [c for c ∈ 0:n+1:n*n - 1]
  cell ∈ diag && join([game.board[c + 1] for c in diag], "") == String(player) ^ n && return true

  # check down diag.
  diag = [c for c ∈ n-1:n-1:n*(n - 1)]
  cell ∈ diag && join([game.board[c + 1] for c in diag], "") == String(player) ^ n
end
