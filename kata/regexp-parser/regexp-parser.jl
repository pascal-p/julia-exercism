const Symbols = Set(['+', '*', '|', '?', '.', '(', ')'])
const Tokens = vcat('a':'z' |> collect, 'A':'Z' |> collect)

const Map_Op_Str = Dict{Char, Union{String, Function}}(
  '+' => "OneOrMore",
  '*' => "ZeroOrMore",
  '|' => "Or",
  '.' => "Any",
  '?' => "Optional",
  '_' => x -> "Normal '$(x)'"  # is for any token ∈ Tokens
  # TODO: support cardinality {1,} == +, {0,} == *, {1,10}
  # TODO: [a-z], [abc] == (a|b)|c
)

const All_Valid_Symbols = vcat(Tokens, Char.(Symbols))

const UTN = Union{Tuple, Nothing}
const UCN = Union{Char, Nothing}
const UBN = Union{Bool, Nothing}
const USN = Union{String, Nothing}
const VS = Vector{String}

#
# Entry point
#
function regexp_parser(regexp::String)::USN
  tuple_res = parser_process(regexp)
  isnothing(tuple_res) && return nothing
  (expr_ary, ops_ary, pch) = tuple_res

  pch == '|' && return nothing # cannot end with pch == '|'
  parser_postprocess(expr_ary, ops_ary)
end

#
# Helper functions
#
@inline normal_expr(ch::Char)::String = Map_Op_Str['_'](ch)

function parser_process(regexp::String)::UTN
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
      result = process_closing_par!(expr_ary, ops_ary, saw_openpar)::UBN
      isnothing(result) && (return nothing)
      saw_openpar = result
    elseif isop(ch)
      result = process_op!(expr_ary, ops_ary, ch, pch)
      isnothing(result) && (return nothing)
    elseif istoken(ch)
      push!(expr_ary, normal_expr(ch))
    else
      return nothing
    end
    pch = ch
  end

  (expr_ary, ops_ary, pch)
end

function parser_postprocess(expr_ary::VS, ops_ary::VS)::USN
  if length(ops_ary) == 0
    "(" ∈ expr_ary && return nothing  # missing closing ")"
    length(expr_ary) == 0 && return nothing
    length(expr_ary) == 1 && return expr_ary[1]

    # 2 more cases: 1. no op startswith Normal,
    #               2. any other op
    startswithnormal(expr_ary[1]) && return tostr(expr_ary)
    return join(expr_ary, " ")
  end

  (length(ops_ary) != 1 || ops_ary[end] != "Or") && return nothing
  length(expr_ary) != 2 && return nothing

  string(ops_ary[end], " ", parenthesize.(expr_ary) |> vs -> join(vs, " "))
end

function process_closing_par!(expr_ary::VS, ops_ary::VS, saw_openpar::Bool)::UBN
  !saw_openpar && return nothing # did not see an opening "("!

  exprs = popuntil!(expr_ary)
  length(exprs) == 0 && return nothing # something is wrong

  last_ops = popuntil!(ops_ary)
  saw_openpar = false

  if length(last_ops) == 1
    length(last_ops) > 1 && return nothing
    length(last_ops) == 0 && return no_ops!(expr_ary, exprs)

    last_ops[1] == "Or" && return or_ops!(expr_ary, exprs, last_ops[1])

    throw(ErrorException("Not implemented yet"))
  end

  # no op to take into account
  length(exprs) == 0 && return nothing

  no_ops!(expr_ary, exprs)
  saw_openpar
end

function no_ops!(expr_ary::VS, exprs::VS)
  length(exprs) == 1 && (push!(expr_ary, exprs[1]); return) # as is...

  push!(
    expr_ary,
    startswithnormal(exprs[1]) ? tostr(exprs) : join(exprs, ", ")
  )
end

function or_ops!(expr_ary::VS, exprs::VS, op::String)::Bool
  length(exprs) != 2 && return nothing
  push!(expr_ary, string(op, " ", parenthesize.(exprs) |> vs -> join(vs, " ")))
  false # NOTE need to return a bool to comply with process_closing_par!
end

function process_op!(expr_ary::VS, ops_ary::VS, ch::Char, pch::UCN)::UCN
  if ch == '*' || ch == '+'
    length(expr_ary) == 0 && return nothing # no operand...
    pch == ch && return nothing # repeating same op!
    ch == '+' && pch == '*' && return nothing
    ch == '*' && pch == '+' && return nothing

    last_expr = pop!(expr_ary)
    push!(expr_ary, string(Map_Op_Str[ch], " ", op_expr(last_expr)))
    #
  elseif ch == '?'
    pch == ch && return nothing # repeating same op!
    (pch == '*' || pch == '+') && return nothing

    last_expr = pop!(expr_ary)
    push!(expr_ary, string(Map_Op_Str[ch],
                           " ",
                           last_expr == "Any" ? "Any" : parenthesize(last_expr)))
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

@inline startswithnormal(expr::String)::Bool = startswith(expr, "Normal")

@inline parenthesize(expr::String) = string("(", expr, ")")

@inline extractfromstr(expr::String)::String = SubString(expr, 6, length(expr) - 1)

@inline tostr(expr::VS; sep=", ")::String = string("Str [", join(expr, sep), "]")

function popuntil!(stack::VS; token= "(")::VS
  exprs = String[]

  while length(stack) > 0 && stack[end] != token
    pushfirst!(exprs, pop!(stack))
  end

  length(stack) == 0 && throw(ArgumentError("Empty expression stack"))

  # case stack[end] == ")"
  pop!(stack)
  exprs
end

function op_expr(expr::String)::String
  expr == "Any" && return "Any"
  # startswith(expr, "Str") && return (parenthesize_expr ∘ extractfromstr)(expr)
  expr |> parenthesize
end
