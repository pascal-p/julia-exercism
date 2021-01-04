const BOARD_DIM = 8

struct Queen{T}
  _r::T
  _c::T
  _d_up::Tuple{T, T}
  _d_down::Tuple{T, T}

  function Queen{T}(row::T, col::T) where T <: Integer
    check_coord(row, col)
    d_up = (-one(T), row + col)
    d_down = (one(T), row - col)
    new(row, col, d_up, d_down)
  end
end

get_pos(q::Queen{T}) where T = (q._r, q._c)

same_col(q::Queen{T}, oq::Queen{T}) where T = q._c == oq._c
same_row(q::Queen{T}, oq::Queen{T}) where T = q._r == oq._r

function same_diag(q::Queen{T}, oq::Queen{T}) where T
  oq._r == q._d_up[1] * oq._c + q._d_up[2] ||
    oq._r == q._d_down[1] * oq._c + q._d_down[2]
end

function can_attack(q::Queen{T}, oq::Queen{T})::Bool where T
  get_pos(q) == get_pos(oq) &&
    throw(ArgumentError("Other queen cannot be at the same position"))

  same_col(q, oq) || same_row(q, oq) || same_diag(q, oq)
end

function check_coord(r::T, c::T) where T
  for x in (r, c)
    1 ≤ x ≤ T(BOARD_DIM) || throw(ArgumentError("Position not in given board"))
  end
end
