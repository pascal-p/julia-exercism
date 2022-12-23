
function resolve(arg1, arg2)
  if typeof(arg1) == Expr && typeof(arg2) == Expr
    (arg1.args[1], arg2.args[1])
    #
  elseif typeof(arg1) == Expr && typeof(arg2) == Symbol
    (arg1.args[1], arg2)
    #
  elseif typeof(arg1) == Symbol && typeof(arg2) == Expr
    (arg1, arg2.args[1])
    #
  elseif typeof(arg1) == Symbol && typeof(arg2) == Symbol
    (arg1, arg2)
  else
    throw(ArgumentError("We should not end up here"))
  end
end

function grab__args(fn_sign)
  if typeof(fn_sign[1]) == Expr && typeof(fn_sign[end]) == Expr
    local arg1, arg2 = fn_sign[1].args[1].args[2], fn_sign[1].args[1].args[3]
    resolve(arg1, arg2)
    #
  elseif typeof(fn_sign[1]) == Expr
    local arg1, arg2 = fn_sign[1].args[2], fn_sign[1].args[3]
    resolve(arg1, arg2)
    #
  elseif typeof(fn_sign[1]) == Symbol
    local arg1, arg2 = fn_sign[2], fn_sign[3]
    resolve(arg1, arg2)
  else
    throw(ArgumentError("We should not end up here"))
  end
end

macro check_undefined_form(fn::Expr)
  local fn_sign = fn.args[1].args
  local r, x = grab__args(fn_sign) # these are the varnames in the target function (cannot be named otherwise)
  fn.args[2] = quote
    iszero(r) && iszero(x) && throw(ArgumentError("Undefined form 0^0"))
    $(fn.args[2])
  end
  fn
end

# macro check_defined_to_power_one(fn::Expr)
#   local fn_sign = fn.args[2].args
#   println(">> fn_sign: ", fn_sign)
#   local r, x =  grab__args(fn_sign)
#   fn.args[2] = quote
#     iszero(x) && return one(typeof(r))
#     $(fn.args[2])
#   end
#   fn
# end
