import Base: push!, popfirst!, empty!
import Base: isempty, length, size, eltype
import Base: first, last, append!
import Base: pushfirst!, convert
import Base: iterate, getindex, setindex!

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
  "Add an element to the back and overwrite front if full"
  ## typeof(item) === typeof(cb.buffer[1]) || throw(TypeError())

  if !isfull(cb)                ## insert at tail (back)
    cb.head == 0 && (cb.head = 1)
    _inc_tail(cb)
    cb.buffer[cb.tail] = item
    cb.occupancy += 1

  else
    if overwrite                ## cb.occupancy remains invariant
      cb.buffer[cb.head] = item ## insert at head (front)
      _inc_head(cb)
      _inc_tail(cb)             ## symetry with  pushfirst!

    else
      throw(BoundsError())      ## buffer is full!
    end
  end
  cb
end

function pushfirst!(cb::CircularBuffer, item; overwrite::Bool=false)
  "Add an element to the front (head) and overwrite back (tail) if full"

  if !isfull(cb)               ## insert before head (front)
    cb.tail == 0 && (cb.tail = cb.capacity)
    _dec_head(cb)
    cb.buffer[cb.head] = item  ## insert at head (front)
    cb.occupancy += 1

  else
    if overwrite                ## cb.occupancy remains invariant
      cb.buffer[cb.tail] = item ## insert at tail (back)
      _dec_tail(cb)
      _dec_head(cb)             ## Need to update head (front) to most recent element in most recent position

    else
      throw(BoundsError())      ## buffer is full!
    end
  end
  cb
end

function append!(cb::CircularBuffer, items; overwrite::Bool=false)
  """
  Push at most last `capacity` items if overwrite is false
  Push everything if overwrite is true (overwritting oldest elements)
  """

  if overwrite
    map(x -> push!(cb, x; overwrite=true), items)

  else
    isfull(cb) && throw(BoundsError())

    n = length(items)
    n = n > cb.capacity - cb.occupancy ? cb.capacity - cb.occupancy : n

    map(x -> push!(cb, x; overwrite=true), 1:n)
  end

  cb
end

function popfirst!(cb::CircularBuffer)
  "Remove the element at the front (head)"
  isempty(cb) && throw(BoundsError()) ## buffer is empty!

  item = cb.buffer[cb.head]
  _inc_head(cb)
  cb.occupancy -= 1

  return item
end

function pop!(cb::CircularBuffer)
  "Remove the element at the back (tail)"
  isempty(cb) && throw(BoundsError()) ## buffer is empty!

  item = cb.buffer[cb.tail]
  _dec_tail(cb)
  cb.occupancy -= 1

  cb.occupancy == 0 && (cb.tail = cb.head = 0)
  return item
end

function empty!(cb::CircularBuffer)
  cb.occupancy = 0
  cb.head, cb.tail = 1, 0

  return cb
end


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


## Iteration ##
function iterate(cb::CircularBuffer{T}, ix::Integer=cb.head) where {T}
  limit = cb.tail < cb.head ? cb.tail + cb.capacity : cb.tail

  if ix ≤ limit
    (cb.buffer[ix], ix + 1)
  else
    nothing
  end
end

## Negative indexing is not supported
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
  istart, iend = if cb.head < cb.tail
    (cb.head, cb.tail)

  elseif cb.head == cb.tail
    if isfull(cb)         ## either full
      (cb.head, cb.tail + cb.capacity - 1)

    else                  ## or 1 item left
      (cb.tail, cb.tail)  ## ≡ (cb.head, cb.head)

    end
  else
    (cb.head, cb.tail + cb.capacity)  ## cb.head ≥ cb.tail, depends how full or empty buffer is...
  end

  if isempty(cb)
    T[]
  else
    T[cb.buffer[ix ≤ cb.capacity ? ix : ix - cb.capacity] for ix in istart:iend]
  end
end

function _offset(cb::CircularBuffer{T}, ix::Integer)::Integer where {T}
  "offset from head of circular buffer"
  !(1 ≤ ix ≤ cb.capacity) && throw(BoundsError())

  jx = cb.head + ix - 1
  jx ≤ cb.capacity ? jx : jx % cb.capacity
end
