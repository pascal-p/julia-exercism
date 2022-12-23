const LIM = 64

extract_arg(arg) = typeof(arg[2]) == Symbol ? arg[2] : arg[2].args[1]

#
# convenience macro whose aim is to inject the following 'guard' condition:
#   ($x ≤ zero(typeof($x)) || $x > LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))
# into the target function body
macro check_int_arg(fn::Expr)
  local x = extract_arg(fn.args[1].args)
  # replace body
  fn.args[2] = quote
    ($x ≤ zero(typeof($x)) || $x > LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))
    $(fn.args[2])
  end
  fn
end

#
# convenience macro whose aim is to inject the following 'guard' condition:
#   $(x) > typeof($(x))(LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))
# into the target function body
#
macro check_uint_arg(fn::Expr)
  local x = extract_arg(fn.args[1].args)
  # replace body
  fn.args[2] = quote
    $(x) > typeof($(x))(LIM) && throw(DomainError("Should be > 0 and ≤ $(LIM)"))
    $(fn.args[2])
  end
  fn
end

#
# use of macros allow for no repetition and more declarative (oneliner) function
#
"""Calculate the number of grains on square `square`."""
@check_uint_arg on_square(square::Unsigned) = (typeof(square))(2) ^ (square - one(typeof(square)))
@check_int_arg on_square(square::Integer) = on_square(Unsigned(square))

"""Calculate the total number of grains after square `square`."""
@check_uint_arg total_after(square::Unsigned) = (typeof(square))(2) ^ square - one(typeof(square))
@check_int_arg total_after(square::Integer) = square > 0 && total_after(Unsigned(square))
