using Base: collect_preferences, byte_string_classify, nothing_sentinel

const Symbols = Set(['+', '*', '|', '?', '.', '(', ')'])
const Tokens = vcat('a':'z' |> collect, 'A':'Z' |> collect)

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
      return nothing
    end
    pch = ch
  end

  pch == '|' && return nothing # cannot end with '|' !

  if length(ops_ary) == 0
    "(" ∈ expr_ary && return nothing  # missing closing ")"
    length(expr_ary) == 0 && return nothing
    length(expr_ary) == 1 && return expr_ary[1]

    # 2 more cases: 1. no op startswith Normal,  2. op
    startswithnormal(expr_ary[1]) && return tostr(expr_ary)
    join(expr_ary, " ")
  else
    (length(ops_ary) != 1 || ops_ary[end] != "Or") && return nothing
    length(expr_ary) != 2 && return nothing

    string(ops_ary[end], " " , parenthesize_expr.(expr_ary) |> vs -> join(vs, " "))
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

    length(last_ops) == 0 && return no_ops!(expr_ary, exprs)

    last_ops[1] == "Or" && return or_ops!(expr_ary, exprs, last_ops[1])

    throw(ErrorException("Not implemented yet"))
  end

  # no op to take into account
  length(exprs) == 0 && return nothing

  no_ops!(expr_ary, exprs)
  saw_openpar
end

function no_ops!(expr_ary::Vector, exprs::Vector)
  length(exprs) == 1 && (push!(expr_ary, exprs[1]); return) # as is...

  push!(
    expr_ary,
    startswithnormal(exprs[1]) ? tostr(exprs) : join(exprs, ", ")
  )
end

function or_ops!(expr_ary::Vector, exprs::Vector, op::String)
  length(exprs) != 2 && return nothing
  lhs, rhs = exprs
  push!(expr_ary, string(op, " (", lhs, ")", " (", rhs, ")"))
  false # NOTE need to return a bool to comply with process_closing_par!
end

function process_op!(expr_ary::Vector, ops_ary::Vector, ch::Char, pch::Union{Char, Nothing})::Union{Char, Nothing}
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

@inline startswithnormal(expr::String)::Bool = startswith(expr, "Normal")

function popuntil!(stack::Vector; token= "(")
  exprs = []

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
  expr |> parenthesize_expr
end

@inline parenthesize_expr(expr::String) = string("(", expr, ")")

@inline extractfromstr(expr::String)::String = SubString(expr, 6, length(expr) - 1)

@inline tostr(expr::Vector; sep=", ")::String = string("Str [", join(expr, sep), "]")
