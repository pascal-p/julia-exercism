const BLACK = :B
const WHITE = :W
const NONE = :_

struct Point
  x::UInt8
  y::UInt::8
end

struct GoBoard
  board::Vector{String}
  x_lim::UInt8
  y_lim::UInt8
end

## Public API

function territory(goboard::GoBoard, x::UInt, y::UInt)::Tuple{String, Set{Point}}
end

function territories(goboard::GoBoard)::Dict{String, Set{Point}}
end

## Private Helpers

## TBD
