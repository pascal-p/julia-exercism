"""
  Difference of Square
  Addressing Integer Overflow
"""

"Square the sum of the first `n` positive integers"
function square_of_sum(n::Integer)::Integer
  # sum(1:n)^2 ≡ (n × (n + 1) / 2)²
  n = _promote(n)
  x₁ = n
  x₂ = x₁ + 1
  x = (x₁ * x₂) >> 1
  return x * x
end

"Sum the squares of the first `n` positive integers"
function sum_of_squares(n::Integer)::Integer
  # 1² + 2² + 3² + ... + n² ≡ (n × (n + 1) × (2n + 1)) / 6
  n = _promote(n)
  x₁ = n
  x₂ = x₁ + 1
  x₃ = (n << 1) + 1
  x = (x₁ * x₂ * x₃) >> 1
  return div(x, 3)
end

"Subtract the sum of squares from square of the sum of the first `n` positive ints"
function difference(n::Integer)::Integer
  n = _promote(n)
  return square_of_sum(n) - sum_of_squares(n)
end


function _promote(n::Integer)::Integer
  "Promote fromn Signed Ints to Unsigned or BigInt"
  if typeof(n) ∈ (Int8, Int16, Int32, Int64)
    n = UInt(n)
  elseif isa(n, Int128)
    n = UInt128(n)
  elseif typeof(n) ∈ [Unsigned, BigInt]
    # nothing
  end
  return n
end
