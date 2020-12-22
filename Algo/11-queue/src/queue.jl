"""
  A dead simple Q (vector based) implementation

  size is allocated once and for all (!) at vreation time...
"""

mutable struct Q{T}
  _data::Vector{T}
  _h::Int      ## head
  _t::Int      ## tail
  _n::Int      ## number of element in the Q

  function Q{T}(n::Int) where T
    @assert n > 0 "The size for the Q should be > 0"

    data = Vector{T}(undef, n)
    h, t = 1, 0
    new(data, h, t, 0)
  end

  function Q{T}(ary::Vector{T}) where T
    n = length(ary)
    data = Vector{T}(undef, n)
    copyto!(data, ary)
    h, t = 1, n
    new(data, h, t, n)
  end
end

## immutable
struct QIter{T}
    q::Q{T}
end


length(q::Q{T}) where T = q._n

function isempty(q::Q{T}) where T
  flag = q._n == 0
  flag && reset!(q)  ## take the opportunity to reset indexes
  flag
end

isfull(q::Q{T}) where T = q._n == length(q._data)

function first(q::Q{T}) where T
  _check_isempty(q)
  q._data[q._h]
end

head(q::Q{T}) where T = first(q)

function last(q::Q{T})::T where T
  _check_isempty(q)
  q._data[q._t]
end

tail(q::Q{T}) where T = last(q)

function enqueue!(q::Q{T}, x::T) where T
  _check_isfull(q)

  q._t += 1
  q._n += 1

  q._t > length(q._data) && (q._t = 1)
  q._data[q._t] = x
  @assert 0 < q._t ≤ length(q._data) "tail of q must be in interval [1, $(length(q))], got: $(q._t)"
end

function dequeue!(q::Q{T})::T where T
  _check_isempty(q)

  x = q._data[q._h]
  q._h += 1
  q._n -= 1

  q._h > length(q._data) && (q._h = 1)
  @assert 0 < q._h ≤ length(q._data) "head of q must be in interval [1, $(length(q))], got: $(q._h)"

  return x
end

reset!(q::Q{T}) where T = q._h, q._t, q._n = 1, 0, 0

iterate(q::Q{T}, st...) where {T} = iterate(QIter{T}(q), st...)

## internal

function iterate(qiter::QIter{T}, (cb, ix)=(qiter.q, qiter.q._h)) where T
  ix > cb._n && return nothing
  x = cb._data[ix ≤ length(cb._data) ? ix : ix - length(cb._data)]

  ix += 1
  return (x, (cb, ix))
end

_check_isempty(q::Q{T}) where T = isempty(q) && throw(ArgumentError("Q is empty"))

_check_isfull(q::Q{T}) where T = isfull(q) && throw(ArgumentError("Q is full"))
