using Base: collect_preferences, byte_string_classify, nothing_sentinel

const Symbols = Set(['+', '*', '|', '?', '.', '(', ')'])
const Tokens = vcat('a':'z' |> collect, 'A':'Z' |> collect)
# const Priority = Dict{String, Integer}(
#   "*" => 3, # unary op
#   "|" => 2, # binary
#   "(" => 1,
#   ")" => 1,
#   "." => 1,
#   # sequence is implicit
# )

const Map_Op_Str = Dict{Char, Union{String, Function}}(
  '+' => "OneOrMore",
  '*' => "ZeroOrMore",
  '|' => "Or",
  '.' => "Any",
  '?' => "Optional",
  '_' => x -> "Normal '$(x)'"  # is for any token ∈ Tokens
)

const All_Valid_Symbols = vcat(Tokens, Char.(Symbols))

normal_expr(ch::Char)::String = Map_Op_Str['_'](ch)

function regexp_parser(regexp::String)::Union{String, Nothing}
  expr_ary, ops_ary = String[], String[]
  saw_openpar, pch = (false, nothing)

  for ch ∈ regexp
    ch ∉ All_Valid_Symbols && return nothing

    if isdot(ch)
      push!(expr_ary, Map_Op_Str[ch])
    elseif ch == '('
      push!(expr_ary, string(ch))
      push!(ops_ary, string(ch))
      saw_openpar = true
    elseif ch == ')'
      result = process_closing_par!(expr_ary, ops_ary, saw_openpar)::Union{Bool, Nothing}
      isnothing(result) && (return nothing)
      saw_openpar = result
    elseif isop(ch)
      result = process_op!(expr_ary, ops_ary, ch, pch)
      isnothing(result) && (return nothing)
    elseif istoken(ch)
      push!(expr_ary, normal_expr(ch))
    else
      throw(ErrorException("Not implemented yet"))
    end

    pch = ch
  end

  pch == '|' && return nothing # cannot end with '|' !

  if length(ops_ary) == 0
    length(expr_ary) == 0 && (return nothing)

    length(expr_ary) == 1 && (return expr_ary[1])
    "(" ∈ expr_ary && return nothing  # missing closing ")"

    # 2 more cases: 1. no op startswith Normal,  2. op
    if startswith(expr_ary[1], "Normal")
      string("Str [", join(expr_ary, ", "), "]")
    else
      join(expr_ary, " ")
    end
  else
    (length(ops_ary) != 1 || ops_ary[end] != "Or") && return nothing
    length(expr_ary) != 2 && return nothing

    string(ops_ary[end], " (", expr_ary[1], ") (", expr_ary[2], ")")
  end
end

function process_closing_par!(expr_ary::Vector, ops_ary::Vector, saw_openpar::Bool)::Union{Bool, Nothing}
  !saw_openpar && return nothing # did not see a opening "("!

  exprs = popuntil!(expr_ary)
  length(exprs) == 0 && return nothing # something is wrong

  last_ops = popuntil!(ops_ary)
  saw_openpar = false

  if length(last_ops) == 1
    length(last_ops) > 1 && return nothing

    if length(last_ops) == 0
      if length(exprs) == 1
        push!(expr_ary, exprs[1]) # as is...
      else
        # length(exprs) > 1
        push!(
          expr_ary,
          startswith(exprs[1], "Normal") ? string("Str [", join(exprs, ", "), "]") :
            join(exprs, ", ")
        )
      end
    elseif last_ops[1] == "Or"
      # binary case
      length(exprs) != 2 && return nothing
      lhs, rhs = exprs
      push!(expr_ary, string(last_ops[1], " (", lhs, ")", " (", rhs, ")"))
    else
      throw(ErrorException("Not implemented yet"))
    end
  else
    # no op to take into account
    length(exprs) == 0 && return nothing

    if length(exprs) == 1
      push!(expr_ary, exprs[1])
    else
      # length(exprs) > 1
      push!(
        expr_ary,
        startswith(exprs[1], "Normal") ? string("Str [", join(exprs, ", "), "]") :
          join(exprs, ", ")
      )
    end
  end
  saw_openpar
end

function process_op!(expr_ary::Vector, ops_ary::Vector, ch::Char, pch::Union{Char, Nothing})::Union{Char, Nothing}
  if ch == '*' || ch == '+'
    length(expr_ary) == 0 && return nothing # no operand...

    pch == ch && return nothing # repeating same op!
    ch == '+' && pch == '*' && return nothing
    ch == '*' && pch == '+' && return nothing

    last_expr = pop!(expr_ary)
    push!(expr_ary,
          string(Map_Op_Str[ch], " ", last_expr == "Any" ? "Any" : "($(last_expr))"))
    #
  elseif ch == '?'
    pch == ch && return nothing # repeating same op!
    (pch == '*' || pch == '+') && return nothing

    last_expr = pop!(expr_ary)
    push!(expr_ary, string(Map_Op_Str[ch], " ", last_expr == "Any" ? "Any" : "($(last_expr))"))
    #
  elseif ch == '|'
    pch == ch && return nothing # repeating same op!
    push!(ops_ary, Map_Op_Str[ch])
  else
    throw(ErrorException("do not know what to do with op $(ch)..."))
  end
  pch
end

istoken(ch::Char)::Bool = ch ∈ Tokens

isop(ch::Char)::Bool = ch ∈ Symbols

isdot(ch::Char)::Bool = ch == '.'

function popuntil!(stack::Vector; token= "(")
  exprs = []

  while length(stack) > 0 && stack[end] != token
    pushfirst!(exprs, pop!(stack))
  end

  length(stack) == 0 && throw(ArgumentError("Empty expression stack"))

  # stack[end] == ")"
  pop!(stack)
  exprs
end
