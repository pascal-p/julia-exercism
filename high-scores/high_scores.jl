TScore = AbstractVector{<: Unsigned}

macro check_scores(fn::Expr)
  local fn_sign = fn.args[1].args
  #
  # NOTE: in each of the following cases we are looking at extracting the function argument: score
  #
  local scores = if typeof(fn_sign[1]) == Expr
    # case - has return type
    # fn_sign == Any[:(latest(scores::TScore)), :Unsigned] ||
    #            Any[:(latest(scores)), :Unsigned] ||
    #            Any[:(latest(scores::TScore = Unsigned[])), :Unsigned]
    local fn_sign_ext = fn_sign[1].args[2]
    typeof(fn_sign_ext) == Expr ?
      (typeof(fn_sign_ext.args[1]) == Symbol ? fn_sign_ext.args[1] : fn_sign_ext.args[1].args[1]) :
      fn_sign_ext # == no type hint
  elseif typeof(fn_sign[1]) == Symbol
    # case - no return type
    if typeof(fn_sign[end]) == Expr
      # fn_sign == Any[:latest, :(scores::TScore)] ||                              => fn_sign[2].args[1]
      #            Any[:latest, :($(Expr(:kw, :(scores::TScore), :(Unsigned[]))))] => fn_sign[2].args[1].args[1]
      typeof(fn_sign[2].args[1]) == Symbol ?
        fn_sign[2].args[1] : fn_sign[2].args[1].args[1] # because it is an Expression
    else
      # fn_sign = Any[:latest, :scores]
      fn_sign[2]
    end
  end
  ## replace body which is fn.args[2]
  fn.args[2] = quote
    # inject the check
    length($scores) == 0 && throw(ArgumentError("scores must be a non empty vector"))
    # copy back the original function body
    $(fn.args[2])
  end
  fn
end


@check_scores latest(scores::TScore)::Unsigned = scores[end]
latest(scores::AbstractVector{<: Integer}) = latest(Unsigned.(scores)) # from Signed ≥ 0 to Unsigned
latest(::Any) = throw(ArgumentError("Expect a vector of (unsigned) Integer"))

@check_scores personal_best(scores::TScore)::Unsigned = maximum(scores)
personal_best(scores::AbstractVector{<: Integer})::UInt = personal_best(Unsigned.(scores)) # from Signed ≥ 0 to Unsigned
personal_best(::Any) = throw(ArgumentError("Expect a vector of (unsigned) Integer"))

@check_scores personal_top_3(scores::TScore)::TScore = sort(scores, rev=true)[1:min(3, length(scores))]
personal_top_3(scores::AbstractVector{<: Integer})::TScore = personal_top_3(Unsigned.(scores)) # from Signed ≥ 0 to Unsigned
personal_top_3(::Any) = throw(ArgumentError("Expect a vector of (unsigned) Integer"))
