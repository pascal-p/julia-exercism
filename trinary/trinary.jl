"""
  Avoid using power, use only multiplication (using horner's schema
  for polynoms)
"""
function trinary_to_decimal(str)::Integer
  isa(str, Char) && (str = string(str))
  str = lstrip(str, [' ', '0'])
  isempty(str) && return 0

  v, d = 0, 3

  for ch in str[1:(end -1)]
    !('0' ≤ ch ≤ '2') && return v = 0
    v = (v + parse(Int, ch)) * d
  end

  ch = str[end]
  !('0' ≤ ch ≤ '2') && return v = 0
  v += parse(Int, ch)

  return v
end
