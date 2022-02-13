
TScore = Vector{UInt}

macro check_scores(fn::Expr)
  local scores = if length(fn.args) ≥ 1 && typeof(fn.args[1].args[1]) != Symbol
    fn.args[1].args[1].args[2].args[1] # with type hint for args and return value
  else
    fn.args[1].args[2]        # w/o any type hint
  end

  ## replace body
  fn.args[2] = quote
    length($scores) == 0 && throw(ArgumentError("scores must not be empty"))
    $(fn.args[2])
  end

  return fn
end

@check_scores latest(scores::TScore)::UInt = scores[end]
@check_scores latest(scores::Vector{<: Integer})::UInt = latest(UInt.(scores))  # will fail if negative score
latest(::Vector{Any}) = throw(ArgumentError("Expect a vector of Int"))

@check_scores personal_best(scores::TScore)::UInt = maximum(scores)
@check_scores personal_best(scores::Vector{<: Integer})::UInt = personal_best(UInt.(scores))
personal_best(::Vector{Any}) = throw(ArgumentError("Expect a vector of Int"))

@check_scores personal_top_3(scores::TScore)::TScore = sort(scores, rev=true)[1:min(3, length(scores))]
@check_scores personal_top_3(scores::Vector{<: Integer})::TScore = personal_top_3(UInt.(scores))
personal_top_3(::Vector{Any}) = throw(ArgumentError("Expect a vector of Int"))
