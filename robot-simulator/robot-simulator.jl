const NORTH = 1
const EAST = 2
const SOUTH = 3
const WEST = 4
const DIRS = (NORTH, EAST, SOUTH, WEST)

import Base: show, ==

# abstract type Point end
mutable struct Point{T <: Integer}
  x::T
  y::T
end

mutable struct Robot
  pos::Point
  dir::Int

  function Robot(pos::Tuple{T, T}, dir::Int) where T <: Integer
    @assert(dir ∈ DIRS,
            "direction should be NORTH, EAST, SOUTH or WEST")
    @assert length(pos) == 2
    # ensure pos is a tuple of Int

    if pos[1] == zero(Int) && pos[2] == zero(Int)
      new(Point{Int}(0, 0), dir)
    else
      new(Point{T}(pos...), dir)
    end
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

function move!(r::Robot, instructions::String)
  for instruction ∈ instructions
    if instruction == "A"
      advance!(r)
    else
    end
  end
  r
end

advance!(r::Robot) = _advance(r) # throw(ArgumentError("Not Inplemented yet!"))

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
