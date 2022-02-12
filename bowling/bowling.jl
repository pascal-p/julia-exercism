import Base: sum

const NUM_FRAMES = 10
const MAX_PINS_VALUE = 10

NInt = Union{<: Integer, Nothing}
PairNInt = Pair{NInt, NInt}
SType = UInt16  # Score Type
ZERO = zero(UInt16)

mutable struct BowlingGame
  pins::Vector{PairNInt}
  pair::PairNInt
  ix::Integer

  function BowlingGame()
    pins = Vector{PairNInt}(undef, NUM_FRAMES + 2)
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

function sum(pair::PairNInt)::SType
  if isnothing(pair.first) && isnothing(pair.second)
    ZERO
  elseif isnothing(pair.second)
    pair.first
  elseif isnothing(pair.first)
    pair.second
  else
    pair.first + pair.second
  end
end


"""
  Record a roll for the current game
"""
function roll!(game::BowlingGame, pins::SType)
  pins > MAX_PINS_VALUE &&
    throw(ArgumentError("pins cannot be more than $(MAX_PINS_VALUE) or less than 0"))

  if game.ix == NUM_FRAMES
    # extra-rolls are allowed provided that last frame was a strike or a spare
    if !isnothing(game.pair.first) && isnothing(game.pair.second)
      # in case of spare we are allowed 1 bonus roll, not 2
      isspare(game.pins[game.ix]) && throw(ArgumentError("Cannot roll more")) # because now we have a full pair which means 2 rolls
      pins == MAX_PINS_VALUE && throw(ArgumentError("Current pins cannot be a strike"))
    else
      # game.pair is empty && last frame was not a spare nor a strike
      sum(game.pins[game.ix]) == ZERO && throw(ArgumentError("Cannot roll more"))
    end
  end

  # bonus because of strike at frame 10 - followed by non strike
  game.ix == NUM_FRAMES + 1 && sum(game.pins[game.ix]) < MAX_PINS_VALUE &&
    throw(ArgumentError("Cannot roll more"))

  # case of a strike
  if pins == MAX_PINS_VALUE && isnothing(game.pair.first)
    game.pair = pins => ZERO
    update_pins!(game)
  else
    if isnothing(game.pair.first)
      game.pair = pins => nothing
    elseif isnothing(game.pair.second)
      game.pair.first + pins > MAX_PINS_VALUE &&
        throw(ArgumentError("frame cannot be > $(MAX_PINS_VALUE)"))
      game.pair = game.pair.first => pins
      update_pins!(game)
    else
      throw(ArgumentError("pair if of length % 2"))
    end
  end
end

function roll!(game::BowlingGame, pins::Int)
  pins < 0 && throw(ArgumentError("pins cannot be less than 0"))
  roll!(game, SType(pins))
end

function score(game::BowlingGame)::SType
  # is there a last (unfinished) pair
  if !isnothing(game.pair.first) && isnothing(game.pair.second)
    game.pair = game.pair.first => ZERO
    update_pins!(game)
  end

  npins, score, n = game.pins, ZERO, game.ix

  (n == NUM_FRAMES + 1) && isstrike(npins[game.ix - 1]) && isstrike(npins[game.ix]) &&
      throw(ArgumentError("Cannot determine score as 10tn and 11th frame were strike")) # would need one more frame

  if n == NUM_FRAMES
    # if strike or spare we need bonus roll(s)
    sum(npins[n]) == MAX_PINS_VALUE && throw(ArgumentError("Missing bonus rolls"))
    score = calc_score(npins, n)

  elseif n > NUM_FRAMES
    sum(npins[n - 1]) != MAX_PINS_VALUE &&
      throw(ArgumentError("Bonus roll(s) are not allowed unless last frame was spare or strike"))

    score = calc_score(npins, n)
  else
    throw(ArgumentError("Less than $(NUM_FRAMES) frames"))
  end

  score
end

"""
   calc_score(npins::Vector{PairNInt})::UInt

Calculate the score given the vector of rolls (or pins)

using a stack to keep track of previous states, most notably whether a
strike or a spare was recorded in a previous frame.
"""
function calc_score(npins::Vector{PairNInt}, n)::SType
  score, cval = fill(zero(SType), length(npins)), ZERO
  stack = fill("", length(npins) + 1)
  stack[1] = "sentinelle"

  for (ix, p) ∈ enumerate(npins[1:n])
    if iszero(sum(p))
      stack[ix + 1] = "open"
      continue # score is already set to 0
    end

    cval = sum(p)
    if cval < MAX_PINS_VALUE
      stack[ix + 1] = "open"
    elseif isstrike(p)
      stack[ix + 1] = "strike"
    else
      stack[ix + 1] = "spare"
    end

    if stack[ix] == "spare"
      score[ix - 1] += p.first # update prev. score
    elseif stack[ix] == "strike"
      # update prev. score
      score[ix - 1] += p.first != MAX_PINS_VALUE ? cval : p.first
      # update prev. prev. score
      ix ≥ 3 && stack[ix - 1] == "strike" && (score[ix - 2] += p.first)
    end

    score[ix] = cval
  end

  sum(score[1:NUM_FRAMES])
end
