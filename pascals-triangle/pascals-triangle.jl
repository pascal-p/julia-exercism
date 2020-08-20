function triangle(n::Integer)
  n < 0 && throw(DomainError("must be > 0"))
  n == 0 && return []
  n ≤ 2 && return map(ix -> ones(Integer, ix), collect(1:n))

  _triangle(n)
end

function _triangle(n::Integer)::Vector{Vector{Integer}}
  ary = map(ix -> zeros(Integer, ix), collect(1:n))  # pre-allocate - limit?
  ary[1][1] = one(n)
  ary[2][1], ary[2][2] = one(n), one(n)

  for y in 3:n
    ary[y][1] = one(1)
    ary[y][y] = one(1)

    for x in 2:(y - 1)
      ary[y][x] = ary[y - 1][x - 1] + ary[y - 1][x]
    end
  end

  ary
end
