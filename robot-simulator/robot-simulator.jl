"""
  Write a robot simulator.

A robot factory's test facility needs a program to verify robot movements.

The robots have three possible movements:

    turn right
    turn left
    advance

Robots are placed on a hypothetical infinite grid, facing a particular direction (north, east, south, or west) at a set of {x,y} coordinates, e.g., {3,8}, with coordinates increasing to the north and east.

The robot then receives a number of instructions, at which point the testing facility verifies the robot's new position, and in which direction it is pointing.

    The letter-string "RAALAL" means:
        Turn right
        Advance twice
        Turn left
        Advance once
        Turn left yet again
    Say a robot starts at {7, 3} facing north. Then running this stream of instructions should leave it at {9, 4} facing west.
"""
const NORTH = 1
const EAST = 2
const SOUTH = 3
const WEST = 4
const DIRS = (NORTH, EAST, SOUTH, WEST)

import Base: == #, show

"""
  Point (mutable) data structure
"""
mutable struct Point{T <: Integer}
  x::T
  y::T
end

"""
  Robot (mutable) data structure
"""
mutable struct Robot
  pos::Point
  dir::Int

  function Robot(pos::Tuple{T, T}, dir::Int) where T <: Integer
    @assert(dir ∈ DIRS,
            "direction should be NORTH, EAST, SOUTH or WEST")
    @assert length(pos) == 2

    new(Point{T}(pos...), dir)
  end
end

## Public API
# show(io::IO, p::Point) = print(io, (p.x, p.y))
iszero(p::Point{T}) where T = p.x == zero(T) && p.y == zero(T)

heading(r::Robot) = r.dir
position(r::Robot) = r.pos

==(p::Point{T}, op::Point) where {T <: Integer} =
  typeof(p) <: typeof(op) && p.x == op.x && p.y == op.y

turn_right!(r::Robot) = _turn!(r, 1)
turn_left!(r::Robot) = _turn!(r, -1)

"""
  move!

Execute succession of instructions given by `instructions` a String

"""
function move!(r::Robot, instructions::String)
  for instruction ∈ instructions |> uppercase
    if instruction == 'A'
      advance!(r)

    elseif instruction == 'L'
      turn_left!(r)

    elseif instruction == 'R'
      turn_right!(r)

    else
      throw(ArgumentError("Instruction is either A, L xor R, got: $(instruction)"))
    end
  end
  r
end

advance!(r::Robot) = _advance(r)

## Internal helpers

function _turn!(r::Robot, dir)::Robot
  "-1 turn left, +1 turn right"
  @assert dir ∈ (-1, 1)

  d = (r.dir + dir) % length(DIRS)
  d = d == 0 ? 4 : d
  r.dir = d
  r
end

function incr(p::Point, sym::Symbol)
  if sym == :x
    p.x += 1
  elseif sym == :y
    p.y += 1
  else
    throw(ArgumentError("either :x xor :y"))
  end
end

function decr(p::Point, sym::Symbol)
  if sym == :x
    p.x -= 1
  elseif sym == :y
    p.y -= 1
  else
    throw(ArgumentError("either :x xor :y"))
  end
end

function _advance(r)::Robot
  if r.dir == NORTH
    incr(r.pos, :y) # r.pos.y += 1
  elseif r.dir == SOUTH
    decr(r.pos, :y) # r.pos.y -= 1
  elseif r.dir == EAST
    incr(r.pos, :x) # r.pos.x += 1
  else
    decr(r.pos, :x) # r.pox.x -= 1
  end
  r
end
