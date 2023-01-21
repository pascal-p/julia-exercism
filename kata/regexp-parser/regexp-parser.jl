using Base: collect_preferences, byte_string_classify, nothing_sentinel

const Symbols = Set(['*', '|', '.', '(', ')'])
const Tokens = vcat('a':'z' |> collect, 'A':'Z' |> collect)
const Priority = Dict{String, Integer}(
  "*" => 3, # unary op
  "|" => 2, # binary
  "(" => 1,
  ")" => 1,
  "." => 1,
  # sequence is implicit
)

const All_Valid_Symbols = vcat(Tokens, Char.(Symbols))

function regexp_parser(regexp::String)::Union{String, Nothing}
  expr_ary, ops_ary = String[], String[]
  saw_openpar, pch = (false, nothing)

  for ch ∈ regexp
    ch ∉ All_Valid_Symbols && return nothing

    if isdot(ch)
      push!(expr_ary, "Any")
    elseif ch == '('
      push!(expr_ary, string(ch))
      saw_openpar = true
      #
    elseif ch == ')'
      !saw_openpar && return nothing # did not see a opening "("!

      exprs = popuntil!(expr_ary)
      saw_openpar = false

      if length(ops_ary) > 0
        last_op = pop!(ops_ary)

        if last_op == "Or"
          # binary
          length(exprs) != 2 && return nothing
          rhs, lhs = exprs
          push!(expr_ary, string(last_op, " (", lhs, ")", " (", rhs, ")"))
        else
          throw(ErrorException("Not implemented yet"))
        end
      else
        length(exprs) == 0 && return nothing

        if length(exprs) == 1
          push!(expr_ary, exprs[1])
        else
          push!(
            expr_ary,
            startswith(exprs[1], "Normal") ? string("Str [", join(exprs |> reverse, ", "), "]") :
              join(exprs, " ")
          )
        end
      end
    elseif isop(ch)
      if ch == '*'
        length(expr_ary) == 0 && return nothing # no operand...
        pch == ch && return nothing # repeating same op!


        last_expr = pop!(expr_ary)
        push!(expr_ary,
              string("ZeroOrMore ", last_expr == "Any" ? "Any" : "($(last_expr))"))
        #
      elseif ch == '|'
        pch == ch && return nothing # repeating same op!
        push!(ops_ary, "Or")
      else
        # return nothing
        throw(ErrorException("do not know what to do with op $(ch)..."))
      end
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
    length(expr_ary) == 1 && (return join(expr_ary, ""))

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

istoken(ch::Char)::Bool = ch ∈ Tokens

isop(ch::Char)::Bool = ch ∈ Symbols

isdot(ch::Char)::Bool = ch == '.'

normal_expr(ch::Char)::String = "Normal '$(ch)'"

function popuntil!(stack::Vector; token= "(")
  exprs = []

  while length(stack) > 0 && stack[end] != token
    push!(exprs, pop!(stack))
    # println("==> stack: $(stack) / exprs: $(exprs)")
  end

  length(stack) == 0 && throw(ArgumentError("Empty expression stack"))

  # stack[end] == ")"
  pop!(stack)
  exprs
end
