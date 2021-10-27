const VALID_OPS = [+, -, *, /, \, ^, %, ==, ≤, ≥, <, >,
                   <<, >>]

function accumulate(ary, op)
  isempty(ary) && return ary

  op ∉ VALID_OPS && throws(ArgumentError("operator not supported"))

  λ = x -> op(x, x)

  return λ.(ary)
end
