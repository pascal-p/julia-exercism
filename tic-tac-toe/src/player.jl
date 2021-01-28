push!(LOAD_PATH, ".")

using Random
using YaGame

abstract type APlayer end;

const Player_Symbols = [ :X, :O ]
const DT = Float32
const NFloat = Union{DT, Nothing}


struct HPlayer <: APlayer
  repr::Symbol

  function HPlayer(symb::Symbol)
    @assert symb ∈ Player_Symbols
    new(symb)
  end
end

struct RPlayer <: APlayer
  repr::Symbol

  function RPlayer(symb::Symbol)
    @assert symb ∈ Player_Symbols
    new(symb)
  end
end

struct CPlayer <: APlayer
  repr::Symbol

  function CPlayer(symb::Symbol)
    @assert symb ∈ Player_Symbols
    new(symb)
  end
end


function get_move(hp::HPlayer, game)
  #
  # TODO
  #
end

get_move(rp::RPlayer, game) = (rand ∘ available_moves)(game)

function get_move(cp::CPlayer, game)::Int
  (length ∘ available_moves)(game) == game.n && return (rand ∘ available_moves)(game)

  _minimax(game, cp.repr, true)[:position]
end

repr(p::APlayer) = p.repr

==(p₁::APlayer, p₂::APlayer) = p₁.repr == p₂.repr

##
## Internal
##

function _minimax(game::Game, cplayer::Symbol, maxp::Bool; α=-Inf32, β=Inf32)::Dict{Symbol, NFloat}
  max_p = maxp ? cplayer : other_player(cplayer)
  oth_p = other_player(cplayer)

  if game.current_winner[1] == oth_p
    return Dict{Symbol, NFloat}(
                                :position => nothing,
                                :score => score_fn(game, max_p, oth_p))
  elseif !has_empty_cells(game)
    return Dict{Symbol, NFloat}(:position => nothing, :score => zero(DT))
  end

  best = Dict{Symbol, NFloat}(:position => nothing,
                              :score =>  cplayer == max_p ? -Inf32 : Inf32)

  for poss_move ∈ available_moves(game)
    ## make a move and eval  its value
    move!(game, poss_move, cplayer)
    sim_score = _minimax(game, oth_p, !maxp; α, β)
    sim_score[:position] = poss_move

    if cplayer == max_p
      best = sim_score[:score] > best[:score] ? sim_score : best
      α = max(α, best[:score] )
      if α ≥ β
        reset!(game, poss_move)
        break
      end

    else
      best = sim_score[:score] < best[:score] ? sim_score : best
      α = min(β, best[:score] )
      if β ≤ α
        reset!(game, poss_move)
        break
      end
    end

    reset!(game, poss_move)
  end

  best
end

other_player(symb::Symbol) = symb == :X ? :O : :X

function score_fn(game, max_p::Symbol, oth_p::Symbol)::NFloat
  f = max_p == oth_p ? one(DT) : -one(DT)
  (num_empty_cells(game) + 1) * f
end
