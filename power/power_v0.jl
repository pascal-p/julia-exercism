TInt = Tuple{Integer, Integer}

function std_power(x::Integer, b::Integer)::TInt
  b < 0 && throw(ArgumentError("exponent should be ≥ 0"))
  x == 0 && b == 0 && throw(ArgumentError("undertermined form"))

  b == 0 && return (1, 0)
  x == 1 && return (1, 0)

  b == 1 && return (x, 0)
  b == 2 && return (x * x, 0)

  c, p = 1, x
  for i in 2:b
    p *= x
    c += 1
  end

  return (p, c)
end

function fast_power_rec(x::Integer, b::Integer)::TInt
  b < 0 && throw(ArgumentError("exponent should be ≥ 0"))
  x == 0 && b == 0 && throw(ArgumentError("undertermined form"))

  b == 0 && return (1, 0)
  x == 1 && return (1, 0)

  b == 1 && return (x, 0)
  b == 2 && return (x * x, 0)

  c = 0
  function f_power(x::Integer, b::Integer)::Integer
    b == 1 && return x

    c += 1
    y = x * x
    p = f_power(y, floor(Int, b / 2))
    return b % 2 == 1 ? x * p : p
  end

  return (f_power(x, b), c)
end

function fast_power(x::Integer, b::Integer)::TInt
  b < 0 && throw(ArgumentError("exponent should be ≥ 0"))
  x == 0 && b == 0 && throw(ArgumentError("undertermined form"))

  b == 0 && return (1, 0)
  x == 1 && return (1, 0)

  b == 1 && return (x, 0)
  b == 2 && return (x * x, 0)

  c = 0
  r, y = 1, x
  b_is_odd = b % 2 == 1

  while b > 1
    if b % 2 == 1
      b -= 1
      r *= y
    else
      r = x * x
      b ÷= 2
    end
    x = r
    c += 1
  end

  # @assert b == 1
  if b_is_odd
    r *= y
    c += 1
  end
  (r, c)
end
