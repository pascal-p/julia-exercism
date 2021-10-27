"""
  Difference of Square
  Addressing Integer Overflow
"""

function square_of_sum(n::Integer)::Integer
  """
  Calculate Square the sum of the first `n` positive integers"

  Σ (1:n)² ≡ (n × (n + 1) / 2)²
  """
  n = _promote(n)
  x₁, x₂ = n, n + 1
  x = (BigInt(x₁) * BigInt(x₂)) >> 1  # FIXME: find better way
  return x * x
end


function sum_of_squares(n::Integer)::Integer
  """
  Sum the squares of the first `n` positive integers

  1² + 2² + 3² + ... + n² ≡ (n × (n + 1) × (2n + 1)) / 6
  """
  n = _promote(n)
  x₁, x₂, x₃ = n, n + 1, (n << 1) + 1
  x = (BigInt(x₁) * BigInt(x₂) * BigInt(x₃)) >> 1 # FIXME: find better way
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

## Helper
"""
   format_n(n::Integer; by=#)::String

Format integer `n` using (default) grouping of 3

# Examples
```jldoctest
julia> format_n(0x000000000034f08787bad496918c3e80)
"64_000_010_666_662_666_666_000_000"

julia> format_n(0x3984232cb3ad882c05658c9b8e800000)
"76_452_092_371_049_684_417_280_099_427_670_818_816"
```
"""
function format_n(n::Integer; by=3)::String
  str_n = string(parse(BigInt, string(n)))

  # calc. len and left pad with 0 to have a multiple of 3
  jx, len_n = 0, length(str_n)

  if len_n % by != 0
     # padding required - find closest multiple of 3
     jx = 1
     while (len_n + jx) % by != 0
        jx += 1
     end

     str_n = string(string("0") ^ jx, str_n)
     len_n += jx
  end

  chunks = [str_n[ix:(ix + by - 1)] for ix in 1:by:len_n]
  return join(chunks, "_")[jx+1:end]
end
