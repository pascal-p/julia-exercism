import Base: push!, popfirst!, empty!
import Base: isempty, length, size, eltype
import Base: first, last, append!, getindex, setindex!
import Base: pushfirst!

abstract type CircularBufferAbstract{T} <: AbstractVector{T} end

mutable struct CircularBuffer{T} <: CircularBufferAbstract{T}
  capacity::UInt
  occupancy:: UInt
  buffer::Vector{T}
  head::UInt
  tail::UInt

  function CircularBuffer{T}(capacity::Integer) where {T}
    capacity ≤ 0 && throw(ArgumentError("Capacity of a circular buffer must be > 0"))

    buffer = Vector{T}(undef, capacity) # [[] for _ in 1:capacity]
    new(capacity, 0, buffer, 1, 0) ## new(capacity, 0, buffer, 1, 1)
  end
end

function push!(cb::CircularBuffer, item; overwrite::Bool=false)
  ## typeof(item) === typeof(cb.buffer[1]) || throw(TypeError())

  if !isfull(cb)  ## insert at tail
    inc_tail(cb)
    cb.buffer[cb.tail] = item
    cb.occupancy += 1

  else
    if overwrite
      cb.buffer[cb.head] = item ## insert at head
      inc_head(cb)
      ## cb.occupancy remains invariant

    else
      throw(BoundsError()) ## buffer is full!
    end
  end

  cb
end

## FIXME: REVIEW !!
function pushfirst!(cb::CircularBuffer, item; overwrite::Bool=false)
  if !isfull(cb)  ## insert before head
    dec_head(cb)
    cb.buffer[cb.head] = item
    cb.occupancy += 1

    if cb.tail == 0
      cb.tail = cb.capacity
    end
      
  else
    if overwrite
      inc_tail(cb)
      cb.buffer[cb.tail] = item ## insert at tail
      ## cb.occupancy remains invariant
      
    else
      throw(BoundsError()) ## buffer is full!
    end
  end
  cb
end

function append!(cb::CircularBuffer, items; overwrite::Bool=false)
  n = length(items)

  if n > cb.capacity - cb.occupancy
    if overwrite

      for item in items
        cb.buffer[cb.head] = item ## insert at head
        inc_head(cb)
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
  inc_head(cb)
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

function first(cb::CircularBuffer{T}) where {T}
  isempty(cb) && throw(BoundsError())
  cb.buffer[cb.head]
end

function last(cb::CircularBuffer{T}) where {T}
  isempty(cb) && throw(BoundsError())
  cb.buffer[cb.tail]
end

function getindex(cb::CircularBuffer{T}, ix::Integer) where {T}
  # TODO: what if ix is < 0
  !(1 ≤ ix ≤ cb.capacity) && throw(BoundsError())

  jx = cb.head + ix - 1 ≤ cb.capacity ? cb.head + ix - 1 : (cb.head + ix - 1) % cb.capacity
  return cb.buffer[jx]
end

function setindex!(cb::CircularBuffer{T}, item::T, ix::Integer) where {T}
  !(1 ≤ ix ≤ cb.capacity) && throw(BoundsError())

  jx = cb.head + ix - 1 ≤ cb.capacity ? cb.head + ix - 1 : (cb.head + ix - 1) % cb.capacity
  cb.buffer[jx] = item
  return
end


## Utilities
for (fn, fdn)  in [(:inc_head, :head), (:inc_tail, :tail)]
  @eval begin
    $fn(cb::CircularBuffer)::UInt = cb.$fdn = cb.$fdn < cb.capacity ? cb.$fdn + 1 : 1
  end
end

for (fn, fdn)  in [(:dec_head, :head), ]
  @eval begin
    $fn(cb::CircularBuffer)::UInt = cb.$fdn = cb.$fdn == 1 ? cb.capacity : cb.$fdn - 1
  end
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
