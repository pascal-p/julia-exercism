using Test

"""
The following macro takes an expression which should return a vector of pairs (of number)
and sort that vector of pair by ascending order on the first element of each pair
"""
macro sort_vp(expr)
  local_vp = gensym(:vp)
  quote
    $local_vp = $(esc(expr)) # eval the expression which returns a vector of pairs
    sort($local_vp, by=p -> p[1])
  end
end

"""
The following macro extends the `@test LHS == RHS` macro by
 1. sort LHS and RHS on the same criteria to allow comparison for vector of pairs where order may be different
 2. compare the sorted result together and conclude
"""
macro yatest(expr)
  # Ensure the input expression is a comparison with the `==` operator
  if Meta.isexpr(expr, :call) && expr.args[1] == Symbol(==)
    _lhs = esc(expr.args[2])
    _rhs = esc(expr.args[3])

    # Apply the @sort_pairs macro to both LHS and RHS
    _sorted_lhs = :(@sort_vp $_lhs)
    _sorted_rhs = :(@sort_vp $_rhs)

    # Use the predefined @test macro for comparing the sorted results
    :(@test ($_sorted_lhs) == ($_sorted_rhs))
  else
    error("Invalid expression for yatest macro. Expected expression in the form `LHS == RHS`.")
  end
end
