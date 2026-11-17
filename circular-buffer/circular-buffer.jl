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
    occupancy::UInt
    buffer::Vector{T}
    head::UInt
    tail::UInt

    function CircularBuffer{T}(capacity::Integer) where {T}
        capacity ≤ 0 && throw(ArgumentError("Capacity of a circular buffer must be > 0"))

        buffer = Vector{T}(undef, capacity)
        new(capacity, 0, buffer, 0, 0)
    end
end

"""Add an element to the back and overwrite front if full."""
function push!(cb::CircularBuffer, item; overwrite::Bool = false)
    ## typeof(item) === typeof(cb.buffer[1]) || throw(TypeError())

    if !isfull(cb)                    ## insert at tail (back)
        cb.head == 0 && (cb.head = 1)
        _inc_tail(cb)
        cb.buffer[cb.tail] = item
        cb.occupancy += 1

    else
        if overwrite                  ## cb.occupancy remains invariant
            cb.buffer[cb.head] = item ## insert at head (front)
            _inc_head(cb)
            _inc_tail(cb)             ## symetry with  pushfirst!

        else
            throw(BoundsError())      ## buffer is full!
        end
    end
    cb
end

"""Add an element to the front (head) and overwrite back (tail) if full."""
function pushfirst!(cb::CircularBuffer, item; overwrite::Bool = false)

    if !isfull(cb)                    ## insert before head (front)
        cb.tail == 0 && (cb.tail = cb.capacity)
        _dec_head(cb)
        cb.buffer[cb.head] = item     ## insert at head (front)
        cb.occupancy += 1

    else
        if overwrite                  ## cb.occupancy remains invariant
            cb.buffer[cb.tail] = item ## insert at tail (back)
            _dec_tail(cb)
            _dec_head(cb)             ## Need to update head (front) to most recent element in most recent position

        else
            throw(BoundsError())      ## buffer is full!
        end
    end
    cb
end

"""
Push at most `capacity - occupancy` items if `overwrite` is `false`.
Push everything if `overwrite` is `true` (overwriting oldest elements).
"""
function append!(cb::CircularBuffer, items; overwrite::Bool = false)
    !overwrite && isfull(cb) && throw(BoundsError())

    src = overwrite ? items : Iterators.take(items, cb.capacity - cb.occupancy)
    for x ∈ src
        push!(cb, x; overwrite)
    end
    cb
end

"""Remove and return the element at the front (head)."""
function popfirst!(cb::CircularBuffer)
    isempty(cb) && throw(BoundsError()) ## buffer is empty!

    item = cb.buffer[cb.head]
    _inc_head(cb)
    cb.occupancy -= 1

    return item
end

"""Remove and return the element at the back (tail)."""
function pop!(cb::CircularBuffer)
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
iterate(cb::CircularBuffer, ix::Integer = 1) = ix > length(cb) ? nothing : (cb[ix], ix + 1)


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
for (fn, fdn) in [(:_inc_head, :head), (:_inc_tail, :tail)]
    @eval begin
        $fn(cb::CircularBuffer)::UInt = cb.$fdn = cb.$fdn < cb.capacity ? cb.$fdn + 1 : 1
    end
end

for (fn, fdn) in [(:_dec_head, :head), (:_dec_tail, :tail)]
    @eval begin
        $fn(cb::CircularBuffer)::UInt = cb.$fdn = cb.$fdn ≤ 1 ? cb.capacity : cb.$fdn - 1
    end
end

_to_ary(cb::CircularBuffer{T}) where {T} = T[cb[i] for i = 1:length(cb)]

"""Compute the 1-based buffer index at offset `ix` from `head`."""
function _offset(cb::CircularBuffer{T}, ix::Integer)::Integer where {T}
    !(1 ≤ ix ≤ cb.occupancy) && throw(BoundsError())
    jx = mod1(cb.head + ix - 1, cb.capacity)
end
