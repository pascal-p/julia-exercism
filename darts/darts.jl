function score(x::Number, y::Number)
  dist = distance(x, y)
  if dist > 10.0
    0
  elseif dist > 5.0
    1
  elseif dist > 1.0
    5
  else
    10
  end
end

score(x::Any, y::Any) = throw(DomainError("Expecting 2 numbers"))

distance(x::Number, y::Number) = √(x ^ 2 + y ^ 2)
