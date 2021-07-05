# a convenience macro
macro check_args(fn::Expr)
  local x_ = if length(fn.args) ≥ 1 && typeof(fn.args[1].args[1]) != Symbol
    fn.args[1].args[1].args[2] # with type hint
  else
    fn.args[1].args[2]         # w/o type hint
  end

  # replace body
  fn.args[2] = quote
    length($(x_)) ≠ 3 && throw(DomainError("We need three positive number exactly"))
    any(x -> x < zero(eltype($x_)), $(x_)) && throw(DomainError("We need three positive number exactly"))

    $(fn.args[2])
  end

  return fn
end

"""
The triangle inequality states that for any triangle, the sum of the lengths of any two sides must be ≥
the length of the remaining side.
"""
check_triangle_inequality(x, y, z)::Bool = x + y ≥ z && x + z ≥ y && y + z ≥ x

@check_args function is_equilateral(sides::Vector{<: Number})::Bool
  all(x -> x == zero(eltype(sides)), sides) && return false
  x, y, z = sides
  x == y == z
end

@check_args function is_isosceles(sides::Vector{<: Number})::Bool
  x, y, z = sides
  !check_triangle_inequality(x, y, z) && return false
  x == y || x == z || y == z
end

@check_args function is_scalene(sides::Vector{<: Number})::Bool
  x, y, z = sides
  !check_triangle_inequality(x, y, z) && return false
  x ≠ y && x ≠ z && y ≠ z
end
