"""
  Given the size, return a square matrix of numbers in spiral order.

The matrix should be filled with natural numbers, starting from 1 in the top-left corner, increasing in an inward,
clockwise spiral order, like these examples:

Spiral matrix of size 3:

1 2 3
8 9 4
7 6 5

Spiral matrix of size 4:

 1  2  3 4
12 13 14 5
11 16 15 6
10  9  8 7

"""
const DT = Matrix{Int}

function spiral_matrix(n::T)::DT where {T <: Unsigned}
  n == zero(T) && return DT(undef, 0, 0)

end

function spiral_matrix(n::Integer)
  @assert n ≥ 0
  spiral_matrix(UInt(n))
end

function spiral_matrix(n::Any)
  throw(ArgumenError("Expecting a positive Integer as argument!"))
end
