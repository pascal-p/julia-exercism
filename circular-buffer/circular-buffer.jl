import Base: push!, popfirst!, empty!
import Base: isempty, length, size, eltype
import Base: first, last, append!, getindex, setindex!
import Base: pushfirst!, convert

abstract type CircularBufferAbstract{T} <: AbstractVector{T} end

"""
head and tail are indexes (pointers) initialized with value 0

"""
mutable struct CircularBuffer{T} <: CircularBufferAbstract{T}
  capacity::UInt
  occupancy:: UInt
  buffer::Vector{T}
  head::UInt
  tail::UInt

  function CircularBuffer{T}(capacity::Integer) where {T}
    capacity ≤ 0 && throw(ArgumentError("Capacity of a circular buffer must be > 0"))

    buffer = Vector{T}(undef, capacity)
    new(capacity, 0, buffer, 0, 0)
  end
end

function push!(cb::CircularBuffer, item; overwrite::Bool=false)
  "add an element to the back and overwrite front if full"

  ## typeof(item) === typeof(cb.buffer[1]) || throw(TypeError())
  if !isfull(cb)  ## insert at tail (back)
    cb.head == 0 && (cb.head = 1)
    _inc_tail(cb)
    cb.buffer[cb.tail] = item
    cb.occupancy += 1

  else
    if overwrite
      cb.buffer[cb.head] = item ## insert at head (front)
      _inc_head(cb)
      ## cb.occupancy remains invariant

    else
      throw(BoundsError()) ## buffer is full!
    end
  end

  cb
end

function pushfirst!(cb::CircularBuffer, item; overwrite::Bool=false)
  "add an element to the front and overwrite back if full"

  if !isfull(cb)  ## insert before head
    cb.tail == 0 && (cb.tail = 1)
    _dec_head(cb)
    cb.buffer[cb.head] = item  ## insert at head (front)
    cb.occupancy += 1

  else
    if overwrite
      cb.buffer[cb.tail] = item ## insert at tail (back)
      _dec_tail(cb)
      ## cb.occupancy remains invariant

    else
      throw(BoundsError()) ## buffer is full!
    end
  end

  cb
end

function append!(cb::CircularBuffer, items; overwrite::Bool=false)
  "push at most last `capacity` items"

  n = length(items)
  if n > cb.capacity - cb.occupancy
    if overwrite

      for item in items
        cb.buffer[cb.head] = item ## insert at head
        _inc_head(cb)
      end

      cb.occupancy = cb.capacity
      cb.tail = cb.head == 1 ? cb.capacity : cb.head - 1

    else
      throw(BoundsError()) ## or append as much items as possible then throw ?
    end
  else # FINE
    # TODO...
  end

  return cb
end

function popfirst!(cb::CircularBuffer)
  isempty(cb) && throw(BoundsError()) ## buffer is empty!

  item = cb.buffer[cb.head] ## popfirst!(cb.buffer[cb.head])
  _inc_head(cb)
  cb.occupancy -= 1

  return item
end

function pop!(cb::CircularBuffer)
  isempty(cb) && throw(BoundsError()) ## buffer is empty!

  item = cb.buffer[cb.tail]
  _dec_head(cb)
  cb.occupancy -= 1

  return item
end

function empty!(cb::CircularBuffer)
  cb.occupancy = 0
  cb.head, cb.tail = 1, 0

  return cb
end

#
# impl: length, size, capacity, isempty, isfull, convert?, pop!
#

capacity(cb::CircularBuffer) = cb.capacity

length(cb::CircularBuffer) = cb.occupancy

size(cb::CircularBuffer)::Tuple = (cb.occupancy,)  ## Tuple

isfull(cb::CircularBuffer) = cb.occupancy == cb.capacity

isempty(cb::CircularBuffer) = cb.occupancy == 0

eltype(cb::CircularBuffer{T}) where {T} = T

convert(::Type{Array}, cb::CircularBuffer{T}) where {T} = _to_ary(cb)

function first(cb::CircularBuffer{T}) where {T}
  isempty(cb) && throw(BoundsError())
  cb.buffer[cb.head]
end

function last(cb::CircularBuffer{T}) where {T}
  isempty(cb) && throw(BoundsError())
  cb.buffer[cb.tail]
end

## negative indexing is not supported
function getindex(cb::CircularBuffer{T}, ix::Integer) where {T}
  jx = _offset(cb, ix)
  return cb.buffer[jx]
end

function setindex!(cb::CircularBuffer{T}, item::T, ix::Integer) where {T}
  jx = _offset(cb, ix)
  cb.buffer[jx] = item
  return
end


## Utilities
for (fn, fdn)  in [(:_inc_head, :head), (:_inc_tail, :tail)]
  @eval begin
    $fn(cb::CircularBuffer)::UInt = cb.$fdn = cb.$fdn < cb.capacity ? cb.$fdn + 1 : 1
  end
end

for (fn, fdn)  in [(:_dec_head, :head), (:_dec_tail, :tail)]
  @eval begin
    $fn(cb::CircularBuffer)::UInt = cb.$fdn = cb.$fdn ≤ 1 ? cb.capacity : cb.$fdn - 1
  end
end

function _to_ary(cb::CircularBuffer{T}) where {T}
  # println(" =DEBUG=> cb.head: $(cb.head) / cb.tail: $(cb.tail)  / cb.tail + cb.capacity: $(cb.tail + cb.capacity)")

  istart, iend = cb.head ≤ cb.tail ? (cb.head, cb.tail) : (cb.head, cb.tail + cb.capacity)
  T[cb.buffer[ix ≤ cb.capacity ? ix : ix - cb.capacity] for ix in istart:iend]
end

function _offset(cb::CircularBuffer{T}, ix::Integer)::Integer where {T}
  "offset from head of circular buffer"
  !(1 ≤ ix ≤ cb.capacity) && throw(BoundsError())

  jx = cb.head + ix - 1
  jx ≤ cb.capacity ? jx : jx % cb.capacity
end


# include("circular-buffer.jl")
# cb = CircularBuffer{Int}(2)
# push!(cb, 100); cb
# push!(cb, 101); cb
# push!(cb, 101); cb    ## Error

# item = popfirst!(cb); cb
# push!(cb, 110); cb

# push!(cb, 105, overwrite=true); cb
# empty!(cb)


# cb = CircularBuffer{Int}(5)

# for i in -5:5
#   println(i)
#   pushfirst!(cb, i; overwrite=true)
#   if i == -1; println(cb.buffer); end
#   if i == 0; println(cb.buffer); end
# end
