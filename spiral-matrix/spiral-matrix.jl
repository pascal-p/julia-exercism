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
  n == one(T) && return ones(eltype(DT), 1, 1)

  mx = DT(undef, n, n)
  k = 0
  incr!() = k += 1                    ## closure

  start_, end_ = (1, n - 1)
  while true
    for ix ∈ start_:end_              ## left -> right
      mx[start_, ix] = incr!()
    end

    for ix ∈ start_:end_              ## right top -> right bottom
       mx[ix, end_ + 1] = incr!()
    end

    for ix ∈ end_ + 1:-1:start_ + 1   ## right bottom -> left bottom
      mx[end_ + 1, ix] = incr!()
    end

    for ix ∈ end_ + 1:-1:start_ + 1   ## left bottom -> top
      mx[ix, start_] = incr!()
    end

    # next iter.
    start_ += 1;
    end_ -= 1;
    end_ == 0 && break
  end

  if n % 2 == 1                       ## case where n is odd
    ix = (n + 1) ÷ 2
    mx[ix, ix] = incr!()
    return mx
  end

  mx
end

function spiral_matrix(n::T)::DT where {T <: Integer}
  @assert n ≥ 0
  spiral_matrix(UInt(n))
end

# Bool can be converted to Int
spiral_matrix(n::Bool) = UInt(n) |> spiral_matrix

spiral_matrix(_::Any) = throw(ArgumentError("Expecting a positive Integer as argument!"))
