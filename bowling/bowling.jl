import Base: sum

const NUM_FRAMES = 10
const MAX_PINS_VALUE = 10

NInt = Union{<: Integer, Nothing}
PairNInt = Pair{NInt, NInt}

mutable struct BowlingGame
  pins::Vector{PairNInt}
  pair::PairNInt
  ix::Integer

  function BowlingGame()
    pins = Vector{PairNInt}(undef, NUM_FRAMES + 1)
    pair = PairNInt(nothing, nothing)
    new(pins, pair, 0)
  end
end

isspare(pair::PairNInt)::Bool =
  pair.first > 0 && pair.second > 0 && sum(pair) == MAX_PINS_VALUE

function isstrike(pair::PairNInt)::Bool
  (pair.first == 0 && pair.second == MAX_PINS_VALUE) || (pair.second == 0 && pair.first == MAX_PINS_VALUE)
end

function update_pins!(game::BowlingGame)
  game.ix += 1
  game.pins[game.ix] = game.pair
  game.pair = nothing => nothing
end

function sum(pair::PairNInt)::Integer
  if isnothing(pair.first) && isnothing(pair.second)
    zero(Integer)
  elseif isnothing(pair.second)
    pair.first
  elseif isnothing(pair.first)
    pair.second
  else
    sum(pair)
  end
end


"""
  Record a roll for the current game
"""
function roll!(game::BowlingGame, pins::Integer)
  (pins < 0 || pins > MAX_PINS_VALUE) &&
    throw(ArgumentError("pins cannot be more than $(MAX_PINS_VALUE) or less than 0"))
  #
  if length(game.pins) == NUM_FRAMES
    # extra-rolls are alowed provided that last frame was a strike or a spare
    if length(game.pair) == 1
      # in case of spare we are allowed 1 bonus roll, not 2
      isspare(game.pins[end]) && throw("Cannot roll more")
      pins == MAX_PINS_VALUE && throw("Current pins cannot be a strike")
    else
      # game.pair is empty && last frame was not a spare nor a strike
      sum(game.pins[end]) == 0 && throw("Cannot roll more")
    end
  end

  # bonus because of strike at frame 10 - followed by non strike
  game.ix == NUM_FRAMES + 1 && sum(game.pins[game.ix]) < MAX_PINS_VALUE &&
    throw(ArgumentError("Cannot roll more"))

  # case of a strike
  if pins == MAX_PINS_VALUE && isnothing(game.pair.first)
    game.pair = pins => 0
    update_pins!(game)
  else
    if isnothing(game.pair.first)
      game.pair = pins => nothing
    elseif isnothing(game.pair.second)
      sum(game.pair.first => pins) > MAX_PINS_VALUE &&
        throw(ArgumentError("frame cannot be > $(MAX_PINS_VALUE)"))
      game.pair = game.pair.first => pins
      update_pins!(game)
    else
      throw(ArgumentError("pair if of length % 2"))
    end
  end
end
