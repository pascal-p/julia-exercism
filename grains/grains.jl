const LIM = 64

#
# convenience macro whose aim is to inject the following 'guard' condition:
#   ($x ≤ zero(typeof($x)) || $x > LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))
# into the target function body
#
macro check_int_arg(fn::Expr)
  local x = if length(fn.args) ≥ 1 && typeof(fn.args[1].args[2]) != Symbol
    fn.args[1].args[2].args[1] # with type hint
  else
    fn.args[1].args[2]         # w/o type hint
  end

  # replace body
  fn.args[2] = quote
    ($x ≤ zero(typeof($x)) || $x > LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))

    $(fn.args[2])
  end

  return fn
end

#
# convenience macro whose aim is to inject the following 'guard' condition:
#  UT = typeof($(x))
#  $(x) > UT(LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))
# into the target function body
#
macro check_uint_arg(fn::Expr)
  local x = if length(fn.args) ≥ 1 && typeof(fn.args[1].args[2]) != Symbol
    fn.args[1].args[2].args[1] # with type hint
  else
    fn.args[1].args[2]         # w/o type hint
  end

  # replace body
  fn.args[2] = quote
    UT = typeof($(x))
    $(x) > UT(LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))

    $(fn.args[2])
  end

  return fn
end


#
# use of macros allow for no repetition and more declarative (oneliner) function
#
"""Calculate the number of grains on square `square`."""
@check_uint_arg on_square(square::Unsigned) = UT(2) ^ (square - one(UT))

@check_int_arg on_square(square::Integer) = on_square(Unsigned(square))

"""Calculate the total number of grains after square `square`."""
@check_uint_arg total_after(square::Unsigned) = UT(2) ^ square - one(UT)

@check_int_arg total_after(square::Integer) = total_after(Unsigned(square))
