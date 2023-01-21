using Base: collect_preferences

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

## map?
# "|" => Or
# "." => Any
# "*" => ZeroOrMore

function regexp_parser(regexp::String)::Union{String, Nothing}
  expr_ary = String[]
  c_ix = 0
  insertion_ix, saw_closing_par = -1, false

  for ch ∈ regexp
    ch ∉ All_Valid_Symbols && return nothing

    # parenthesis '(' => mark index for insertion
    (ch == '(') && (insertion_ix = c_ix + 1; continue) # (insertion_ix = length(expr_ary); continue)

    # parenthesis ')'
    (ch == ')') && (saw_closing_par = true; continue)

    c_ix += 1

    istoken(ch) && (push!(expr_ary, normal_expr(ch)); continue)

    isdot(ch) && (push!(expr_ary, "Any"); continue)

    if isop(ch)
      if ch == '*'
        # do we have parenthesis? yes use insertion_ix and reset it
        if saw_closing_par
          # ex: ...(bc)*
          elements = []
          println("c_ix: $(c_ix), insertion_ix: $(insertion_ix)")
          for _ in (c_ix - 1):-1:insertion_ix
            pushfirst!(elements, pop!(expr_ary))
          end
          elements_str = string("Str [", join(elements, ", "), "]") # ex. ZeroOrMore (Str [Normal 'b', Normal 'c'])
          push!(expr_ary, string("ZeroOrMore (", elements_str, ")"))
          insertion_ix, saw_closing_par = (-1, false)
        else
          # No (no parenthesis)
          last_expr = pop!(expr_ary)
          push!(expr_ary,
              string("ZeroOrMore ", last_expr == "Any" ? "Any" : "($(last_expr))"))
        end

        continue
      end
    end
  end

  println("Found $(expr_ary)")

  if length(expr_ary) == 1
    join(expr_ary, "")
  elseif startswith(expr_ary[1], "Normal")
    string("Str [", join(expr_ary, ", "), "]")
  else
    join(expr_ary, "")
  end
end

istoken(ch::Char)::Bool = ch ∈ Tokens

isop(ch::Char)::Bool = ch ∈ Symbols

isdot(ch::Char)::Bool = ch === '.'

normal_expr(ch::Char)::String = "Normal '$(ch)'"
